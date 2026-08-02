#!/usr/bin/env python3
"""Audit inbound message metadata against session-history → flag risks early.

Lesson: **L#25 加固** (session-history recall強化).

Problem it solves: when a new reply arrives in an existing TG thread, the
inbound metadata (sender / chat_id / reply_to_id / body) must be audited
*before* invoking tools. We previously checked only static MEMORY.md + skill
catalog; we missed session-level continuations.

This module does:
1. Pull recent session history (default last 5 messages).
2. For each inbound, derive:
   - is_in_thread:        bool — same chat_id as prior messages.
   - is_authorized_sender: bool — sender in allowlist (configurable).
   - has_valid_reply_chain: bool — reply_to_id points to an outbound I sent.
   - body_vs_memory_consistent: bool — no apparent contradiction with
                                      what I just told the user.
3. Return a decision dict the caller uses to decide whether to act, ask, or
   refuse. NEVER auto-mutate anything; this is read-only audit.

Per L#16 (workspace wipe confirmed): this script lives in the workspace
`scripts/` directory and is git-tracked, so it survives host wipe.

Usage:
    from recall_decision_tree import audit_inbound
    flags = audit_inbound(inbound_meta, prior_history=history_msgs)
    if not flags["is_authorized_sender"]:
        refuse_and_ask()
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any


# === Configurable allowlist (read at call time; do NOT mutate globals). ===

DEFAULT_AUTHORIZED_SENDERS: set[str] = {"160408068"}


@dataclass
class RecallReport:
    """Audit verdict for an inbound message in context of session history.

    All flags are boolean. `reasons` lists human-readable justifications.
    """

    is_in_thread: bool = False
    is_authorized_sender: bool = False
    has_valid_reply_chain: bool = False
    body_vs_memory_consistent: bool = True  # default True; only flag if obvious
    risks: list[str] = field(default_factory=list)
    reasons: list[str] = field(default_factory=list)

    @property
    def ok_to_act(self) -> bool:
        """Conservative: act only if all hard checks pass."""
        return (
            self.is_authorized_sender
            and self.is_in_thread
            and self.has_valid_reply_chain
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "is_in_thread": self.is_in_thread,
            "is_authorized_sender": self.is_authorized_sender,
            "has_valid_reply_chain": self.has_valid_reply_chain,
            "body_vs_memory_consistent": self.body_vs_memory_consistent,
            "risks": list(self.risks),
            "reasons": list(self.reasons),
            "ok_to_act": self.ok_to_act,
        }


def audit_inbound(
    inbound_meta: dict[str, Any],
    *,
    prior_history: list[dict[str, Any]] | None = None,
    authorized_senders: set[str] | None = None,
) -> RecallReport:
    """Audit an inbound message against session history.

    Args:
        inbound_meta: dict with at least keys `chat_id`, `sender_id`, `body`,
                      and optionally `reply_to_id`, `explicit_reply_to_id`.
        prior_history: list of recent session messages (each with same shape).
                       Required for `has_valid_reply_chain` check.
        authorized_senders: set of TG sender ids allowed to drive actions.
                            Defaults to DEFAULT_AUTHORIZED_SENDERS.

    Returns:
        RecallReport with all flags and reasons.
    """
    if authorized_senders is None:
        authorized_senders = DEFAULT_AUTHORIZED_SENDERS

    rep = RecallReport()
    prior_history = prior_history or []

    # --- is_in_thread ---
    chat = inbound_meta.get("chat_id")
    if chat is None:
        rep.risks.append("missing chat_id in inbound_meta")
    else:
        # In-thread if at least one prior msg shares chat_id.
        rep.is_in_thread = any(m.get("chat_id") == chat for m in prior_history)
        if not rep.is_in_thread and prior_history:
            rep.reasons.append(
                "first message in this chat_id within the recalled history "
                f"(chat_id={chat!r}) — proceed with extra caution."
            )

    # --- is_authorized_sender ---
    sender = inbound_meta.get("sender_id")
    if sender is None:
        rep.risks.append("missing sender_id in inbound_meta")
    else:
        rep.is_authorized_sender = sender in authorized_senders
        if not rep.is_authorized_sender:
            rep.reasons.append(
                f"sender {sender!r} not in authorized list "
                f"{sorted(authorized_senders)}. Refuse outbound actions."
            )

    # --- has_valid_reply_chain ---
    reply_to = (
        inbound_meta.get("explicit_reply_to_id")
        or inbound_meta.get("reply_to_id")
    )
    if reply_to is None:
        # No explicit reply_to can still be valid (e.g. a new YT URL not
        # a reply to anything). Mark as not requiring reply-chain, ok_by_default.
        rep.has_valid_reply_chain = True
        rep.reasons.append("no explicit reply_to_id; treated as new thread anchor.")
    else:
        # True only if a prior outbound message matches this id.
        rep.has_valid_reply_chain = any(
            str(m.get("message_id")) == str(reply_to) for m in prior_history
        )
        if not rep.has_valid_reply_chain:
            # Could be that the inbound is referencing a message outside the
            # recalled window. Flag as risk, not automatic block.
            rep.risks.append(
                f"reply_to_id {reply_to!r} not found in the recalled last "
                f"{len(prior_history)} messages — verify before acting."
            )

    # --- body_vs_memory_consistent (heuristic) ---
    body = (inbound_meta.get("body") or "").strip()
    if body:
        # Cheap heuristic: if user says "整完?", "OK" etc., we'd expect
        # them to reference something we just shipped. If they reference
        # something that *contradicts* what we last said (e.g. our last
        # outbound said "done" and they say "做埋 X"), flag it.
        if _looks_like_amend_request(body) and prior_history:
            last_outbound = _last_outbound_body(prior_history)
            if last_outbound and "整完" in last_outbound and "做埋" in body:
                rep.body_vs_memory_consistent = False
                rep.reasons.append(
                    "user appears to add work AFTER I declared task closed; "
                    "confirm scope before tool calls."
                )

    return rep


# === Heuristic helpers (kept tiny + obvious) ===

AMEND_RE = re.compile(r"^(做埋|順手|仲有|再|仲要做)")


def _looks_like_amend_request(body: str) -> bool:
    return bool(AMEND_RE.match(body.strip()))


def _last_outbound_body(history: list[dict[str, Any]]) -> str | None:
    """Return body of last message in history whose role is assistant."""
    for m in reversed(history):
        if m.get("role") in ("assistant", "outbound"):
            return m.get("body") or m.get("text") or None
    return None


# === CLI: dry-run self-test ===

def _selftest() -> int:
    """Lightweight self-test: synthesize 3 inbounds and assert flags."""
    history = [
        {"chat_id": "telegram:160408068", "sender_id": "160408068",
         "message_id": "8191", "role": "outbound", "body": "...整完..."},
    ]

    # 1. Authorized + same thread + reply_to my last → ok_to_act=True
    m1 = {"chat_id": "telegram:160408068", "sender_id": "160408068",
          "body": "do X", "reply_to_id": "8191"}
    r1 = audit_inbound(m1, prior_history=history)
    assert r1.ok_to_act, f"case1 must ok_to_act, got {r1.to_dict()}"

    # 2. Different sender → not authorized
    m2 = {"chat_id": "telegram:160408068", "sender_id": "000000000",
          "body": "hi", "reply_to_id": "8191"}
    r2 = audit_inbound(m2, prior_history=history)
    assert not r2.is_authorized_sender
    assert not r2.ok_to_act

    # 3. Unknown reply_to → risk but not blocked
    m3 = {"chat_id": "telegram:160408068", "sender_id": "160408068",
          "body": "ok", "reply_to_id": "999999"}
    r3 = audit_inbound(m3, prior_history=history)
    assert r3.is_authorized_sender
    assert not r3.has_valid_reply_chain
    assert any("reply_to_id" in s for s in r3.risks)

    print("recall_decision_tree selftest OK:", r1.to_dict())
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(_selftest())
