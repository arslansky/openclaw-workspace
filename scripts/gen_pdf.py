#!/usr/bin/env python3
"""
Zeabur PDF Generator
Usage: python3 gen_pdf.py "Hello World" output.pdf
       python3 gen_pdf.py --file input.txt output.pdf
"""
import sys, os

def make_pdf_from_text(text_content, output_path, font_size=10, margin=20):
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.cidfonts import UnicodeCIDFont
    from reportlab.lib.pagesizes import A4
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
    from reportlab.lib.styles import ParagraphStyle
    from reportlab.lib.units import mm

    pdfmetrics.registerFont(UnicodeCIDFont('STSong-Light'))

    doc = SimpleDocTemplate(
        output_path,
        pagesize=A4,
        leftMargin=margin*mm,
        rightMargin=margin*mm,
        topMargin=margin*mm,
        bottomMargin=margin*mm
    )

    style = ParagraphStyle(
        'CJK',
        fontName='STSong-Light',
        fontSize=font_size,
        leading=font_size * 1.4,
    )

    story = []
    for line in text_content.split('\n'):
        line = line.rstrip()
        if not line:
            story.append(Spacer(1, 4))
        else:
            story.append(Paragraph(line, style))

    doc.build(story)
    size = os.path.getsize(output_path)
    print(f"OK: {output_path} ({size} bytes)")
    return output_path

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python3 gen_pdf.py <text_or_file> <output.pdf>")
        sys.exit(1)

    content_or_path = sys.argv[1]
    output = sys.argv[2]

    if os.path.isfile(content_or_path):
        with open(content_or_path, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        content = content_or_path

    make_pdf_from_text(content, output)
