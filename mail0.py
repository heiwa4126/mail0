#!/usr/bin/env python
#-*- coding: utf-8 -*-
# pylint: disable-msg=C0103, C0111
"""
Python2でメールを送る。
"""

import sys
import re
import subprocess


from email.mime.text import MIMEText
from email.header import Header


JIS = 'ISO-2022-JP'
# jis = 'UTF-8'

def getUnicode(s):
    if type(s) is str:
        s = s.decode('utf-8')
    return s

def getJisStr(s):
    return getUnicode(s).encode(JIS)

def splitAU(s):
    return re.findall(r'([ -~]*)([^ -~]*)', getUnicode(s))

def mimeHead(s):
    z = splitAU(s)
    h = Header('')
    for a,u in z:
        if a != '':
            h.append(a)
        if u != '':
            h.append(u.encode(JIS), JIS)
    return h

me = 'heiwa4126@example.net'
you = '"heiwa4126" <heiwa4126@example.com>'
body = """(yyyy-mm-dd) バックアップが成功しました。

その他いろいろ
いろいろ
いろいろ
いろいろの最後

現在時刻:""" + subprocess.check_output('date', shell=True)


msg = MIMEText(getJisStr(body), 'plain', JIS)
msg['From'] = mimeHead(me)
msg['To'] = mimeHead(you)
msg['Subject'] = mimeHead('ここがタイトルだ!!!')

# print(msg.as_string()); sys.exit(0)

# # sendmailコマンドを使って送信する場合
# from subprocess import Popen, PIPE
# p = Popen(["/usr/sbin/sendmail", "-t", "-oi"], stdin=PIPE)
# p.communicate(msg.as_string())

# SMTPを使って送信する場合
import smtplib
s = smtplib.SMTP('localhost')
s.sendmail(me, [you], msg.as_string())
s.quit()
