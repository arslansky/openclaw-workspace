#!/usr/bin/env python3
"""
Code Review Stop Hook
檢查檔案有冇 REVIEWED marker，冇就擋住並觸發 review
"""

import sys
import os
import re
import subprocess
from pathlib import Path

MARKER_PATTERN = r'<!--\s*REVIEWED:\s*\d{4}-\d{2}-\d{2}.*-->'
REVIEW_CHECKLIST = Path('/root/.openclaw/workspace/REVIEW_CHECKLIST.md')

def check_marker(file_path):
    """檢查檔案結尾有冇 REVIEWED marker"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        return bool(re.search(MARKER_PATTERN, content))
    except Exception as e:
        print(f"❌ 讀取檔案失敗: {e}")
        return False

def needs_review(file_path):
    """判斷檔案是否需要審核"""
    # 只檢查 code 檔案
    code_extensions = {'.py', '.js', '.ts', '.jsx', '.tsx', '.go', '.rs', '.java', '.cpp', '.c', '.h', '.sh'}
    ext = Path(file_path).suffix
    if ext not in code_extensions:
        return False
    
    return not check_marker(file_path)

def trigger_review(file_path):
    """觸發 review process - 輸出指令俾用戶執行"""
    print(f"\n🛑 STOP HOOK 觸發!")
    print(f"   檔案: {file_path}")
    print(f"   狀態: 未經審核 (冇 REVIEWED marker)")
    print(f"\n📋 下一步:")
    print(f"   1. 讀取 checklist: cat {REVIEW_CHECKLIST}")
    print(f"   2. 開 reviewer session 審核呢個檔案")
    print(f"   3. 通過後加 marker 到檔案結尾")
    print(f"\n💡 或者如果你確定唔需要審核，手動加 marker:")
    print(f'   echo "<!-- REVIEWED: $(date +%Y-%m-%d) by manual --><!-- REVIEW_CHECKSUM: skipped -->" >> {file_path}')
    return 1

def main():
    if len(sys.argv) < 2:
        print("用法: python review_hook.py <file_path>")
        print("\n或者檢查整個目錄:")
        print("  python review_hook.py --scan <directory>")
        sys.exit(1)
    
    if sys.argv[1] == '--scan':
        # 掃描目錄
        target_dir = sys.argv[2] if len(sys.argv) > 2 else '.'
        print(f"🔍 掃描目錄: {target_dir}")
        
        files_needing_review = []
        for root, dirs, files in os.walk(target_dir):
            # 跳過常見非 code 目錄
            dirs[:] = [d for d in dirs if d not in {'.git', 'node_modules', '__pycache__', 'venv', '.env'}]
            
            for file in files:
                file_path = os.path.join(root, file)
                if needs_review(file_path):
                    files_needing_review.append(file_path)
        
        if files_needing_review:
            print(f"\n⚠️  發現 {len(files_needing_review)} 個檔案需要審核:")
            for f in files_needing_review:
                print(f"   - {f}")
            sys.exit(1)
        else:
            print("\n✅ 所有檔案已審核通過!")
            sys.exit(0)
    else:
        # 檢查單個檔案
        file_path = sys.argv[1]
        if not os.path.exists(file_path):
            print(f"❌ 檔案不存在: {file_path}")
            sys.exit(1)
        
        if needs_review(file_path):
            sys.exit(trigger_review(file_path))
        else:
            print(f"✅ 檔案已審核: {file_path}")
            sys.exit(0)

if __name__ == '__main__':
    main()
