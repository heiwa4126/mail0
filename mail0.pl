#!/usr/bin/env perl
# -*- coding: utf-8 -*-
# とにかく追加ライブラリを使わないでメール送るコード
# その分コードがぐちゃぐちゃ。
# 使えるならEmail::Sender使え。

use utf8;
use strict;
use warnings;
use feature qw(switch say);
use feature ":5.16"; # for __SUB__
my $ioc = ( $^O =~ /WIN/i ) ? ':encoding(cp932)' : ':utf8';
binmode STDIN  => $ioc;
binmode STDOUT => $ioc;
binmode STDERR => $ioc;

use Encode;
use POSIX qw(strftime locale_h);
use constant JIS => 'ISO-2022-JP';
use constant MJIS => 'MIME-Header-ISO_2022_JP';

sub mimeHead {
  join('',map{encode(MJIS,$_)}(grep{$_ ne ''}($_[0] =~ m/([ -~]*)([^ -~]*)/g)));
}
sub date2822 {
  my $old_locale = setlocale(LC_CTYPE);
  setlocale(LC_TIME, 'C');
  my $rc = strftime('%a, %d %b %Y %H:%M:%S %z', localtime);
  setlocale(LC_TIME, $old_locale);
  $rc;
}

my $me = getpwuid($>);
my $host = `hostname -f`; chomp($host); utf8::decode($host);

my $s =<<"EOL";
From: "$me" <$me\@$host>
To: "Foo Bar" <foobar\@example.net>
Cc: "Buz Aldrin" <buz\@example.org>,
 "heiwa4126" <heiwa4126\@example.com>
Date: @{[date2822()]}
Subject: @{[mimeHead("ここらがタイトルだ!!!")]}
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit

EOL

my $body =<<'EOL';
(yyyy-mm-dd) バックアップが成功しました。

その他いろいろ
いろいろ
いろいろ
いろいろの最後
EOL

$s .= encode(JIS,$body);
# say $s; exit 0;

# sendmailコマンドで送信
open(my $mail, '|sendmail -t') or die($!);
print $mail $s;
close($mail) or die($!);

# ローカルのMTAが正しく設定されていない場合 or
# SMTPのアドレスを与えられたような場合、
# Net::SMTP が標準モジュールなのでそれを使う
# use Net::SMTP;
# my $smtp = Net::SMTP->new('111.222.333.444', Debug => 0);
# $smtp->mail($from);
# $smtp->to($to);
# $smtp->data();
# $smtp->datasend($s);
# $smtp->dataend();

0;
