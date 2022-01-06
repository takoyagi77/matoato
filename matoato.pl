use utf8;	# 文字列をutf8として扱う
use Encode;	# 文字コード変換 encode()/decode()ライブラリ
# use open IO => ":encoding(cp932)";	# ファイルはSJISとして扱う
use Encode::Guess qw/cp932 utf8 euc-jp/;	# SJISの他にUTF-8,EUCも扱えるようにする 200701
use Cwd 'getcwd';
# binmode(STDIN,":encoding(cp932)") ;		# 標準入力は，SJIS
# binmode(STDOUT,":encoding(cp932)") ;	# 標準出力は，SJIS
# binmode(STDERR,":encoding(cp932)") ;	# 標準エラーも，SJIS
# @ARGV = map { decode('cp932',$_) } @ARGV ;	# コマンド引数をutf8とする。"/$pat/"のため @array1=map{equation(using $_)}@array;で@arrayの要素をequationに沿って変換を行い、@array1に格納する decodeで外部文字列を内部文字列に変換

#
#use encoding "cp932";
#$/ = "\r\n";

#######  スイッチの設定
$H_DEBUG=0;	# txt2tex0.tmpなど中間ファイルを消すとき０
$H_DEBUG1=0; # tmpは残して、ignor.dat,label.datを消すとき０ ==> label.datが残ってるとデバッグ作業が面倒なため
$H_BACK=1; # backup用のフォルダを作成し、コピーをそこに保存する場合1 200701
$H_PICTURE=1; # 写真をpictureフォルダに保存する場合1 200701
$H_PICTURE_1=1; # 写真をpictureフォルダに移動する場合1 201001
$S_JCODE=1; # 文字コードを自動判別する場合1 200701
$S_WARNING=1; # エラー文をtxtに書く場合1 201226
# $MATOATORC_PATH = '/home/users/kimura/test/test1/';	# インストーラが書き換える
$MATOATORC_PATH = 'c:/home/kimura/httpd130e/matoato/';	# インストーラが書き換える
$H_OS = 'MS-Windows';	$H_JCODE = 'sjis';	#---- OS, 日本語コードの設定
#$H_OS = 'Linux';		$H_JCODE = 'euc';	#---- OS, 日本語コードの設定
#$H_OS = 'Macintosh';	$H_JCODE = 'sjis';	#---- OS, 日本語コードの設定
$H_PERL_VER=2;



#####################################################
#	perlの注意点
#####################################################
#	「.*」に\nは含まれない
#	s///g のとき $1=$2=...='' となる

#	while($_){}は $_="0"のとき$_=""とみなされるので while(length($_)>0){}とすべき
#	$bef='。、'; $aft='．，'; y/$bef/$aft/; ... うまくいかない
#	if( /(章|節)：/ ) は節：しかかからない　→　if( /[章節]：/ )だと章：，節：の両方かかる

#	$1, $2 などを初期化するとき //; と書けばよい。

# main.pl		... find "taotao"
# readme.txt	... find "print_readme"
# fig_ex1.obj	... find "print_fig_ex1.obj"
# txt2tex.pl	... find "matomato txt2tex"
# tex2txt.pl	... find "ayato tex2txt"

#####################################################
#	Tgif4.1.8の注意点
#	日本語ペースト ... 編集 竏驤 ファイルからぺ竏茶Xト
#####################################################

#####################################################
#	まとあと txt2tex/tex2txt 変更点
#####################################################
# DOS版の特有の残課題 with Perl 5 ****************
#	◯DOS版:debug: readme.txtがあるときreadme_1.txtを作らない→作る ... readme~1.txtと見えるのでうまくいかない, 000723b
# Mac版(v0.4)の特有の残課題 with MacJPerl 5.1 ****************
#	○main:debug(Mac版): readme_1.txtなど ..._1 が作られなず、readme.txtが上書きされる(open(LS,"ls|")のバグ？)
#	◯tex2txt:debug(Mac版): '＾ ~￣α^{β+ ab}_{γ - δ}'のように＾と~の間にスペースを挿入してしまう．
#	◯txt2tex:debug(Mac版): '\newtheorem{theorem}{定理}'が\sectionより後ろに書かれてしまう．
#	◯txt2tex:debug(Mac版): 「	図：ず（fig.eps）	%aaa」 のとき処理ミスする
# ActivePerl 5.8.0 for win32 特有の残課題 ****************
#	○perl580bug: 2byte 文字の length が１になるためtex2txtの表、式がずれる。（no encoding では３。jperlは２。）

#
# mainの未対応の処理 ************************************
#	◯main:readme: latex2htmlは fancybox.sty のコマンドを表示できないので、これの代わりを使う -> txt: \fbox{\verb| ... |}... 1行だけ, tex: \rule でどうか
#
# tex2txtの未対応の処理 ************************************
#	◯tex2txt:debug: $aa$ -> "$aa$" となってしまう --> "YD" + "XN" (990104j) と、連続したa-zは""で囲む仕様にしているけど...どうしよう
#	◯tex2txt:debug:Ⅰ縲怫\は、unix ではスペースとして表示されるので、latexmoji変換はマズイ
#	◯tex2txt:debug(fatal error): fancybox.styを tex2txt すると無限ループ！
#		-------- 必要かと思ったけど不要な処理 ----------------
#	◯tex2txt:debug: 表：が入れ子のとき、そのまま"\begin{tabular}...&...\end{tabular}"と書いて、|c||l| の決定のとき、入れ子の tabular の中の & がtxt2texによって無視されるようにする。←000517dで十分
#
#
# txt2texの未対応の処理 ************************************
#	◯txt2tex:debug: \newtheorem{proof}, theorem, lemmaなどが既に定義済のとき定義しない。
#	◯txt2tex:debug: 参考文献の p.~44 → p.$\tilde {}$44 → p.~44 (p.~44は p.44と見える）
#	◯次の変換が未かも

#	表：A(s) "and "B(s)	（tbl:resultAB）
#	"\centering"
#	◯本文中に"\newtheorem{theorem}{定理}"などが書かれているとき、これをget_BEGINNING(000213c)で書かない
#	◯"定理："以外でもいいようにすべき(例、"仮定："を"\newtheorem{MadeByTxt2tex_0}{仮定}"に変換), 9812??d
#	◯debug: \begin{tabular}{|cl||l|l|} -> \begin{tabular}{|c||l|l|}
#		|c||l| の決定のとき、入れ子の tabular の中の & を無視する。
#		 ↑ 難しいので表入れ子を書くときの注意事項としておき、処理しない。今後、下記、表の機能アップで対応する。
#	◯表：の機能アップ 一部だけ横罫線を書く ... \cline{2-3} ２から３行に罫線, てくてくTeX, 上 p.178
#	◯表：の機能アップ \multicolumn{2}{|c||}{a & b} & "c"\\ を使って下表も書けるようにする, 9812??
#			{2}つの行に{|c||}の形式で{abc}を書く, てくてくTeX, 上 p.176
#		----------
#		|a|b|| c | ← これを書けるようにする(\multicolumn)
#		==========
#		| a || d |
#		|	||---| ← これを書けるようにする(\cline{2-2})
#		| b || e |
#		----------
#
#		-------- 必要かと思ったけど不要な処理 ----------------
#	◯{a}_{{n}_{a}}← a_{na} と変換する ← 不要
#	◯無駄な処理'	（）'... 式なしで式番号だけつける処理を削除する ← ダメ！：横幅が狭くて式番号を下の行にずらすことがあるので
#	◯式ラベル"("（eqn:2.1）")"と書いていても（eqn:2.1）と見なす←不要?
#

#************************************** txt2tex → tex2txt と繰り返したときのバグ
$bug000813 = <<"-bug000813";

	287c287
	< 式番号の参照ラベルは（eqn:5）"縲鰀"（eqn:7）式と書きます。 #縲鰀は～の意
	---
	> 式番号の参照ラベルは（"eqn:5"）"縲鰀"（"eqn:7"）式と書きます。
	509c509
	< 	"\mbox {"例"："	　あああ（ it : 1）"}"
	---
	> 	 "\mbox {"例"："	　あああ	（it:1）"}"
	511c511
	< 	&& "\mbox {"例"："	　"Abc1": あああ（ it :1）"}"
	---
	> 	&& "\mbox {"例"："	　"Abc1": あああ	（it:1）"}"
	516c516
	< 	 "\mbox {"例"："	　"Item"（Item2）"→" "Item2"}
	---
	> 	 "\mbox {"例"："	　"Item"（Item2）"→" "Item2}"


	791c791
	< 	\mbox {例：	　あああ（ {i_{t}}	&:& 1）}
	---
	> 	\mbox {例：	　あああ	（{i_{t}}	&:& 1）}
	799c799
	< 	&& \mbox {例：	　Abc1: あああ（ {i_{t}} :1）}
	---
	> 	&& \mbox {例：	　Abc1: あああ	（{i_{t}}:1）}
-bug000813
$bug000813 =~ s/^\t//;
$bug000813 =~ s/\n\t(\t){0,1}/\n$1/g;
#	◯txt2tex:debug: "○●◎○◇□△"(txt) -> 記号は:;.,．)｝]"）"｝」。"・"，"○"●◎○"◇□△▽☆"★●◆■▲◎"◯〇"(txt) -> "○●◎$\bigcirc$◇□△" と無変換なのに変換してしまう
#		記号は":;.,．)\}]）｝」。・，○●◎○◇□△▽☆★●◆■▲◎◯〇"			(txt)
#				↓
#		記号は:;.,．)\}]）｝」。・，○●◎○◇□△▽☆★●◆■▲◎◯〇				(tex)
#				↓								↓この◯がおかしい...""で囲まれてない
#		記号は:;.,．)｝]"）"｝」。"・"，"○"●◎○"◇□△▽☆"★●◆■▲◎"◯〇"	(txt)
#				↓
#		記号は:;$.,$．)\}]）\}」。・，○●◎$\bigcirc$◇□△▽☆★●◆■▲◎◯〇	(tex)
#	◯tex2txt:debug: "(kimura@cherry.yyy.or.jp)" -> ("kimura"@"cherry.yyy.or.jp") と "" の中に @ が入ってないので入れる

#	◯tex2txt:debug:"  " -> ” ” と半角スペース2つが1つになってしまう。
#	◯main:debug: makeみたいに時間依存を完璧にする
#	◯txt2tex:debug: x^(2) → x^\left(2\right) ← latex error となるので x^{\left(2\right)}となるようにする
#
#**************************************
#
#### 今後の予定

#	・・・ linux, dos, mac 版リリース
#	・・・ StepIdentIEEE.tex -> txt -> tex をttyファイルレベルで完璧にする
#
#020501
#	○txt2tex:debug: 題名：の前の行に %題名： があると題名処理されない
#	○txt2tex:debug: #undef	英文：があると#define 英文：が全くキャンセルされる
#	○txt2tex:debug: [#define 英文： /*aaa*/] と行末にコメント入れると英文モードにならない。
#	○readme:正確に: コメントは /* */ or #if 0 だけ。% はtxt2texで変になることがある
#
#220101(ver0.9.8)
# 	〇eqn2tex?:本文中に「＝を含む数式」と「"」で囲われた文字が3つ以上の時(他の条件もありそう)正しく処理できてない
#		ex.「a=15"3"89"dB"、40.1"dB"」 -> 「$a=15$389dB，$40.$dB1」
#	〇txt2tex:「\%」をそのまま表示したい
#-------------------------------------------------------
############		Version 履歴(begin)		############
#-------------------------------------------------------
$VER=	'まとあと txt2tex/tex2txt 0.9.8, ななみん, 220101';#■□■□■□■□■□■□■□■□
	#	〇subfig2tex:「複複」の実装：「複」の独立バージョン
	#	〇subfig2tex:n×mで図を配置可能に
#$VER=	'まとあと txt2tex/tex2txt 0.9.7, ななみん, 211101';#■□■□■□■□■□■□■□■□
	#	〇fig2tex:「here」パッケージの「H」オプションを「強制」で記述可能なように
#$VER=	'まとあと txt2tex/tex2txt 0.9.6, ななみん, 211001';#■□■□■□■□■□■□■□■□
	#	〇txt2tex:「節節節」の新設
	#	〇subfig:debug:拡張子を含まないファイル名を指定されたときの挙動がおかしかったのを修正
#$VER=	'まとあと txt2tex/tex2txt 0.9.5, ななみん, 210801';#■□■□■□■□■□■□■□■□
	#	〇main:「platex」から「uplatex」へ変更
	#	〇txt2tex:文字コード自動判別が機能していなかったのを修正
#$VER=	'まとあと txt2tex/tex2txt 0.9.4, ななみん, 210701';#■□■□■□■□■□■□■□■□
	# 	〇txt2tex:機能追加：txtにまとあとwarningを書き込む
	# 	〇txt2bib:削除：色々あった
	#	〇subfig:機能追加：「複」コマンド追加、m×nで画像配置が可能に
	#	〇main:機能追加：subfile用の設定追加、引数にsubdirectryのファイルを指定しても実行可能に
	#	〇txt2tex:機能追加：「章＊」で「section*」への変換が可能に
#$VER=	'まとあと txt2tex/tex2txt 0.9.3, ななみん, 201101';#■□■□■□■□■□■□■□■□
	# 	〇CELsty:変更：全面一新
#$VER=	'まとあと txt2tex/tex2txt 0.9.2, ななみん, 201001';#■□■□■□■□■□■□■□■□
	#	〇main:機能追加：eps,jpg,pngを全てpictureフォルダに移動。
	#	〇bib2tex:変更：BiBTeX用に変更。詳しくはtxt2bibを参照。
#$VER=	'まとあと txt2tex/tex2txt 0.9.1, ななみん, 200901';#■□■□■□■□■□■□■□■□
	#	〇dvi,pdf:変更：platexを書き込みモードで無いと動作しなかった。書き込みファイルを「test3.txt」としていたが、txtは使われている可能性があるため「test3.tmp」に変更
	#	〇tab2tex:機能追加：表全体のサイズ調整が不可能だったため、\t表：Caption（Label,上下ここ,右中左,\normalsize）でサイズ調整可能に。
#$VER=	'まとあと txt2tex/tex2txt 0.9.0, ななみん, 200901';#■□■□■□■□■□■□■□■□
	#	〇WindowsとMacintosh(OS名はそれぞれMSWin32,darwin)に対応。Darwinで動作するように作成したためMSWin32の人は0.8.2の方が安定しておすすめ
	#		入力ファイルはCRLF限定。出力ファイルはMSWin32はCRLF、DarwinはLF
	#		Darwinは「--pdf,--txt2tex」のみ動作確認。「--pdfpv」は動作しないと思われる。他の引数はおそらく動作するはず
	#		Darwinにおいてdvi及びpdf作成時何故か書き込みモードにしないと動作しないぽい？
#$VER=	'まとあと txt2tex/tex2txt 0.8.2, ななみん, 200701';#■□■□■□■□■□■□■□■□
	#	〇set_output_file:機能追加：「filename_backup」のフォルダを作成し、そこにbackupファイルを移動(デフォルトはオフ)
	#	〇txt2tex:機能追加：「\grahicspath{{./picture/}}」の記述(デフォルトはオフ)
	#	〇txt2tex:機能追加：入力ファイルの文字コードを判別してopenする(デフォルトはオフ)。対応文字コードはSJIS,UTF-8,EUC
	#						出力ファイルはSJIS
	#	〇get_BEGINNING:機能追加：「kosakalab2020.sty」用の設定を追加 => 「\papersetting{?}」が記述されていれば
	#	既存	題名："title" -> \title{title} -> \title{?}{title}  作成："author" -> \author{author} -> \author{?}{author}
	#	新規	英語題："engtitle" -> \ENGtitle{?}{engtitle}  英語作："engauthor" -> \ENGauthor{?}{engauthor}  概要："abstract" -> \abstract{"abstract"}  鍵："keywords" -> \kwywords{"keywords"}
	#	〇main:機能追加：ControlEngineeringLab.styとAnnual.styを内蔵。それぞれ引数を「--CELsty」と「--ANNUALsty」とすれば出力される。
#$VER=	'まとあと txt2tex/tex2txt 0.8.1, ななみん, 200624';#■□■□■□■□■□■□■□■□
	#	〇Active Perl 5.26.3推奨。Active Perl 5.12.4でも動作確認済み
	#	〇TeX Live2020のインストールを推奨。ないと「--pdfpv」コマンドは使用不可	Thanks for たかぴー
	#	〇debugを行った。ver.0.7からLaTeXの仕様が大分変わっていたため以前のファイルをコンパイルする際は見直しが必須。以下注意点を考慮すればver0.7で作成した卒論をコンパイルできたため、大きな変化はない...はず
	#		注意点：\LaTeXや\TeXが数式モード内で使用できない
	#				ダブルクォーテーションで囲った中に数式モードで使う文字（ギリシャ文字等々）は数式モードにする必要がある	ex. 以前："～ \alpha"	現在："～ $\alpha$"
	#				ギリシャ文字等々に下付きする場合は「\phi_{uy}」もしくは「φuy」と記述。以前は「\phi_u_y」と記述しないと正しい表示にならなかったため注意
	#	〇subfig:debug:文書のpointが10pt以外の時でも横向きの画像が一行に入るように修正
	#	〇latexmk:仕様変更：「latexmk -c」を実行するのを中止
#$VER=	'まとあと txt2tex/tex2txt 0.8, ななみん, 200624';#■□■□■□■□■□■□■□■□
	#	〇9年ぶりの修正。perl5.26.3に対応、2020年に適したLaTeX文章への変換 (*∂v∂)ﾐﾅｾｲﾉﾘ
	#	〇Visual Stdio Codeでの開発を行うにあたって可読性向上のためコメントを追加、#挿入位置変更
	#	〇perl5.12.4=>perl5.26.3で一部環境が変化していたため適した形にした
	#	〇txt2tex:仕様変更：fig2texをeps以外にpng,jpgを対応させた
	#	〇txt2tex:仕様変更：複数の図を1つの図として挿入を可能に subfig
	#		実施内容：subfigを参照。「	[縦横]：Figcaption（Figlabel,position：Subfigcaption1（filename1,Subfiglabel1,size倍）,Subfigcaption2（filename2,Subfiglabel2,size倍）,...）」で可能(順不同...のはず)
	#		未実装：n行n列形で画像を挿入できない
	#		検討点：\refする際、図4(c)のようにしている。図4cか図4(c)にするか選択できたらいいのかも？
	#	〇main:機能追加：latexmkによるコンパイル方法を追加
	#		検討点：コンパイル成功の際中間ファイルを削除する設定にしているが、残してもいいかも？
	#		課題点："latexmk -pvc"に対応するようなプログラムの作成
	#	〇subfigはtex2txtには未対応、というかtex2txtは触ってない
#$VER=	'まとあと txt2tex/tex2txt 0.7, 110903';#■□■□■□■□■□■□■□■□
	#	○txt2tex:仕様変更：￣{a+b}->{\bf a+b}となって\bar{a}+bとおなじになってしまうので{\overline a+b}に変更110817a, \overline{ a+b}に変更110823a
	#	○txt2tex:仕様変更：\usepackage{bigtabular}があるときは、\begin{Tabular}を使う110810e
	#	○txt2tex:debug：k1/(-a + b) もfrac処理できるようにする110810d
	#	○txt2tex:仕様変更：frac処理で{(s+b1)(s+b2)…}/{(s+a1) (s+a2)+ …}もできるように…、・を式文字として設定110810c
	#	○txt2tex:仕様変更：表の中に「図：（abc,0.5倍）」→\includegraphics[width=0.5\hsize]{abc}に書き換え110810b
	#	○txt2tex:debug：表：〇〇（abc,左中）→左左(ll)となってしまう110810a
	#	○txt2tex:仕様変更：箇条書きの式とその後の文章（"%","","\"まで）をitemの続きとみなす（旧は式のみitem）110808a-->ダメできない！複雑すぎて断念。式と箇条書きの順番が狂う
	#		実施内容：次の部分を削除「\end{enumerate}\n\begin{eqnarray}」＋if($_ eq %\n, \n, \\abc）のとき\end{enumerate}でlist終了
	#	○txt2tex:仕様変更：箇条書きの\nonumberの行を削除（なんで入れてたのか？）110806
#$VER=	'まとあと txt2tex/tex2txt 0.6, 110726';#■□■□■□■□■□■□■□■□
	#	○8年ぶりの修正。win7では動かなくなったので、perl5.12.4に対応させた。sjis専用。jcode.plから完全分離。ver. 0.6にアップ 110726
	#	○"～"の文字化けを修正
#$VER=	'まとあと txt2tex/tex2txt 0.51未, たおくま, 030925';#■□■□■□■□■□■□■□■□
	#	○txt2tex:debug perl5.8.0: perl5.8.0のエラー対策。030825a
	#	○tex2txt:debug \verb+abc+ の+を\+にするように変更。030827a
	#	○tex2txt:仕様変更：u\left(t\right) → u(t) にするように変更。→"縲鰀"が"\sim"にならないバグが発生。(y(t)+1)の外括弧が大きくならないのでヤメ！030918
	#	○txt2tex:仕様変更：%\maketitle と書いていると \maketitle を書かないようにする。030921
	#	○txt2tex:仕様変更：#define 章： '章："\rm "'のように'で囲んでスペースを扱う。030925
	#koko
	#	○tex2txt:debug perl5.8.0: ・ｽ・ｽ_{i=0}^{N}が変になる。未
	#	○txt2tex:仕様変更：#define X 1 と#if X==1 や #ifdef などをＣ並みに使えるようにする。
	#
#$VER=	'まとあと txt2tex/tex2txt 0.50, たおくま, 030903';#■□■□■□■□■□■□■□■□
	#	○matoato: ActivePerl 5.8.0 for win32 にも対応させた。, perl580
	#		インストール： jperl5: matoato.pl のコードを EUC にして、最上部数行のコメントを操作。
	#					   perl5.8以降: matoato.pl のコードを utf8 にして、最上部数行のコメントを操作
	#	○tex2txt: latex2eの\figureに対応させる。030813
	#
#$VER=	'まとあと txt2tex/tex2txt 0.44, たおくま, 030408';#■□■□■□■□■□■□■□■□
	#	久しぶり（1年半ぶり）に開発再開！
	#	○仕様変更：LaTeX 2.09 → latex2e に変更, 010612にやりたいと思い、020322に実行
	#		txt2texの仕様変更・・・020322a
	#		tex2txtの仕様変更・・・020322b
	#		readme.txtなどの変更・・・020322d
	#		**** latex 2.09→latex2eの変更箇所 ****
	#		\documentstyle[psbox,twocolumn]{...}
	#			:
	#		\psbox[xsize=0.9\hsize]{file.eps} \\
	#			↓
	#		\documentclass[twocolumn]{...}
	#		\usepackage[dvips]{graphicx}
	#			:
	#		\includegraphics[width=0.9\hsize]{file.eps}\\
	#	○main:debug:dosでiran.tex→iran_1.tex→iran_2.tex とならない(set_output_file) 020322c
	#	○txt2tex:仕様変更： ^#undef 定理： or 証明：、補題：のとき \newtheorem{...を書かない 020322e
	#	◯txt2tex:debug: dosで使っていて、日本語ゼロの文章を変換すると EUC となり\newtheorem{定理：}でlatexエラー発生 020323a
	#	○txt2tex:debug:	) (　をeqnすると \right) \left(となりlatex error → \rightの左に\leftが無いと\rightを消す, 020323b
	#	○txt2tex:debug:	{(i)} ) をeqnすると	&& { \left.\left(i\right)} \right) となりlatex error→原因：\left.や\right.を付け足すときカッコの入れ子を無視している！
	#	○txt2tex:仕様変更:"作成："を書かないと \author{} を書かないようにした。\jauthorなど学会フォーマットを使うとき邪魔なので。030317
	#	○txt2tex:仕様変更:\authorが２つあるとコメントしていた→ControlEngineeringPractice学会フォーマットは２つ以上使うのでコメントせずエラーメッセージのみにした。030408
	#
#$VER=	'まとあと txt2tex/tex2txt 0.43, たおくま, 000814';#■□■□■□■□■□■□■□■□
	#	・・・ readme.ttyとreadme_1.ttyの1回目の変換以降、dviファイルの同一性を保つ(再現性確保!)
	#	・・・ HTML版 GUIまとあと との整合をとる。(HTML, PS, PDF, xdvi対応、インストーラ作成)
	#	◯main:機能追加: matoato --install でインストールできるようにした。(linuxとMS-Win),000813a
	#	◯main:機能追加: matoato --txt2unix でeuc+LFできるようにした。(txt2dos, txt2mac, h2zも),000813b
	#	◯main:機能追加: matoato --dvi, --html, --ps, --pdf対応（とりあえず版）,000813c
	#	◯tex2txt:debug: $aaa$\n$bbb$ を aaa bbb にしているが、aaa\ bbbに変更, 000813d
	#					 $aaa$$bbb$ = $aaa\ bbb$となるかチェック要！
	#	◯tex2txt:仕様変更:Ⅰ表：，箇条書：の後に空行を入れて見栄えをよくしたい．000813e
	#	◯tex2txt:debug: \~bear(tex) -> "~bear"(txt) と \ が消えてしまう,000813f
	#		txt2texの仕様： ~"bear" -> $\tilde{}$bear と変換する(~a のときは \tilde{a})
	#	◯txt2tex:debug: \begin{verbatim}\n \documentstyle[psbox,a4j]{jarticle}\n \end{verbatim}があると、\documentstyleが定義済とみなしてしまう000813g
	#	◯txt2tex:debug: ”（,[中左右）”(txt) → "（$,[$中左右）"(tex) → "（,[中左右）"(tex) 000813h
	#	◯main:仕様変更: matoato readme.ps が readme.tex を造る → readme.ps.tex に変更,000813i
	#					拡張子を削除して置き換えるのは、txt,tao,texのみで、他は追加する
	#
	#	○main:仕様変更: readme.txtが既にある時、オリジナルをreadme_1.txtに mv してreadme.txtに出力する000813j
	#	日付が未？◯main:機能追加: dvi,html,ps,pdf変換のとき .matoatorc を読込む000813k
	#		matoato --pdf readme.txtなどの仕様：
	#			   拡張子が省略されているとき、txtとみなす
	#			→ txt より tex の日付が新しいとき tex をターゲットにする	if not → txt2tex
	#			→ tex より dvi の日付が新しいとき dvi をターゲットにする	if not → jlatex
	#			→ dvi より ps  の日付が新しいとき ps  をターゲットにする	if not → dvips
	#			→ ps  より pdf の日付が新しいとき何もしない				if not → ps2pdf
	#	◯txt2tex:debug: 箇条書の中身が消える000813l
	#    　・"matoato --fig\_ex1.obj：マニュアルに挿入するTgifファイルを出力します。"
	#    　　　"matoato --help > readme.txt"
	#		  ↓
	#    $\cdot$matoato --fig\_ex1.obj：マニュアルに挿入するTgifファイルを出力します
	#        \nonumber  
	#    \item
	#	◯tex2txt:debug: "（,[$a$中b左右）"(tex) → ”"（,[a中b左右）"”(txt)→”（,[a中"b"左右）”(txt),000813m
	#	◯tex2txt:debug: 下記バグ,000813n
	#	:$aaa$
	#	:    $bbb$
	#		  ↓
	#	:"$\ bbb$" となってaaaが消えてしまう
	#	◯txt2tex:debug: (あ) → (あ )と余分なスペースを挿入してしまう。000813o
	#	◯main:仕様変更: matoato ../../readme.tex のとき ./readme.txt を作っていたが、../../readme.txt を作るようにする000813p
	#
	#	○debug: $tmp が$  tmp となっていた 000814
	#
	#
#$VER=	'まとあと txt2tex/tex2txt 0.42, たおくま, 000801';#■□■□■□■□■□■□■□■□
	#	・・・ readme_1.texとreadme_1_1.tex ... 、readme_1.txtとreadme_1_1.txt ... と2回目の変換以降、同一性を保つ(再現性確保!)
	#	◯tex2txt:debug: ', ' --> ',' とスペースが消える,000801a
	#    表：
	#    ------------------------------------------------------------
	#    | ノルム || ｜x^2｜, 窶堀1窶髦, 窶堀ab窶髦1, 窶麻ｿ1窶髦2, 窶麻ﾓa窶磨蜀 |
	#    ============================================================
	#    |   式   || a = lim_{t→∞} ∫ β1(t)/Φa(t) dt            |
	#    ------------------------------------------------------------
	#			↓
	#    表：
	#    ----------------------------------------------------------
	#    | ノルム||  ｜x^2 ｜,窶堀1窶髦,窶堀ab窶髦1 ,窶麻ｿ1窶髦2 ,窶麻ﾓa窶磨・
	#    ==========================================================
	#    | 式    || a = "lim"_{t→∞} ∫(β1(t))/(Φa(t)) "dt"    |
	#    ----------------------------------------------------------
	#	◯tex2txt:debug: 'LaTeX'の前後へのスペース挿入を止める, 00801b,000801g
	#		txt2tex: 'LaTeX'   --> '\LaTeX 'と後ろだけスペース挿入する仕様となっている
	#
	#		tex2txt: '\LaTeX ' --> 'LaTeX'と前にスペースないとき後ろだけスペース削除(00801g)
	#	◯tex2txt:debug: eqnの中の\mbox{を"\mbox{"にする, 000801c
	#		\begin{eqnarray}
	#		    && \mbox{例： 　あああ    （it:1）}
	#		        \nonumber
	#		\end{eqnarray}
	#				↓
	#			\mbox {例"：" 　あああ "（it:1）"}
	#	◯txt2tex:debug: 10 -> $10$をやめる（数字のみはdollarしない）,000801d
	#	◯tex2txt:debug: \lim が "lim" になったのを lim にする。,000801e
	#		(dt|cos|sin|tan|exp|lim|Figure|figure|Fig|fig|Table|table|max|min)→ "..."不要
	#	◯txt2tex:debug: "・主な" -> "$\cdot$ 主な" とスペ竏茶X挿入されるのをやめる。000801f
	#	◯tex2txt:debug: 1節：LaTeX スタイル（節：LaTeX スタイル） と不要な（...）が残る,000801h
	#	◯txt2tex:仕様変更: txt2tex0.tmpやignor.datなどをデフォルトで消す（$H_DEBUG=0のとき消す）,000801i
	#	◯tex2txt:debug: verbatimのバグ ... 行がずれる,000801j
	#
	#		\begin{ovalboxFrame}
	#		\begin{verbatim}
	#		    \documentstyle[psbox,a4j]{jarticle}
	#		\end{verbatim}
	#		\end{ovalboxFrame}
	#
	#				↓
	#		\begin{verbatim}
	#		    \documentstyle[psbox,a4j]{jarticle}
	#		\end{verbatim}
	#		　"\begin{ovalboxFrame}"
	#		　"\end{ovalboxFrame}"
	#	◯txt2tex:debug: \mbox{...}の...を "..." にする処理が"\mbox{"のときもイキになってしまっている。(000625n)000801k
	#	◯tex2txt:debug: 下のようにスペースを挿入してしまう。000801l
	#		｜x^2｜
	#				↓
	#		\left |x^2\right | ,
	#				↓
	#		｜x^2 ｜
	#				↓
	#		\left |x^2 \right | ,
	#				↓
	#		｜x^2  ｜,
	#				↓
	#		\left |x^2  \right | ,
	#	◯tex2txt:debug: 下のように表にスペースを挿入してしまう。000801m
	#	   | ワープロ | ×     |  △   |  △           || 醜く重く難しい|
	#				↓
	#	   | ワープロ | ×     |  △   |  △           ||  醜く重く難しい|
	#	◯tex2txt:debug: StepIdentIEEE.tex を #define 英文： で箇条書内の(\ref{eqn:def:M_AB}) → (（eqn:def:M_AB）), 000801n
	#	◯tex2txt:debug: 行末にスペースを挿入してしまう。..."  %aaa"の%以前のスペースが残っていた。000801o
	#		"\end{Sbox}\setlength{\fboxsep}{8pt}\shadowbox{\TheSbox}}" 
	#	◯tex2txt:debug: 未対応の\begin{}...\end{}があるとき改行されない．000801p
	#
	#		\begin{shadowboxFrame}
	#		${\frac{a}{b}}$
	#		\end{shadowboxFrame}
	#				↓
	#		　"\begin{shadowboxFrame}"a/b"\end{shadowboxFrame}"
	#	◯仕様変更: Ｖ <--> \bigvee など全角アルファベットを LaTeX特有の文字への置き換えをやめる。000801q
	#		ZenA_Z0_9toHanの処理とぶつかってややこしいので、ZenA_Z0_9toHanを優先する(Α＝２とよく書くが\bigveeを書くことはまずないので)。
	#	◯tex2txt:debug: スペースを挿入してしまう．＾~￣α^{β+ ab} --> ＾~￣α^{β+  ab},000801r
	#	◯tex2txt:debug: $...$のとき改行が無視される。000801s
	#		$\alpha^{\beta+ {a}}$
	#		
	#		$\beta+ {a_{b}}$
	#				↓
	#		α^{β+ a} β+  ab
	#	◯tex2txt:debug: $a$\n$a$ -> aa となってしまう -> a a とスペースを挿入,000801t
	#	◯tex2txt:debug: fracによるreadme_1.txtとreadme_2.txtのスペースのありなしの差をなくす(不完全)000801u
	#	◯txt2tex:debug: fracによるreadme.texとreadme_1.texのスペースのありなしの差をなくす(無駄な{...}を削除)000801v
	#					 ({\frac{a}{b}}) -> (\frac{a}{b})と不要な{...}をつけない
	#	◯英文:debug: 式だけのtxtを英文：と判断してしまう。→[a-z]\.がないとき和文にする,000801w
	#	◯tex2txt:debug: $(0\sim 9,$ 0$\sim$9) --> (0 縲鰀 9, 0縲鰀"9)" --> (0 縲鰀 9, 0縲鰀9), 000801x
	#	◯tex2txt:debug: \verb|\mbox{\boldmath $...$}| --> \verb|"\mbox{\boldmath" ..."}|”と \verbの中なのに""を挿入してしまう000801y
	#	◯tex2txt:debug: ａ-ｚＡ-Ｚ０-９ を半角にしていたが、全角であるという情報がなくなるので、変換しない。000801z
	#
	#
#$VER=	'まとあと txt2tex/tex2txt 0.41, たおくま, 000723';#■□■□■□■□■□■□■□■□
	#	・・・ 日本語コードを自動変換
	#	◯機能追加: SJISで使うと /あん/ は perl error → jcodeでperl内部は EUC で処理, 000723a
	#	◯DOS版:debug: readme.txtがあるときreadme_1.txtを作らない→作る ... readme~1.txtと見えるのでうまくいかない, 000723b
	#	◯Mac版:debug: print_()は$H_JCODEでなく、$H_OSでコードを選ぶ, 000723c
	#	◯txt2tex:debug: '式'が、SJISのとき'ョ'に文字化け -- SJISの式はEUCのョと同じで読み込み時にこの文字しかないとき、SJIS->EUC変換されない --> 強制的に変換する, 000723d
	#	◯機能追加：全角アルファベットを、ベクトルや行列の \boldmath として変換する
	#
	#		→ 変換したくないものまで、たくさん変換してしまいそうなので readme.txt に紹介だけする
	#
	#			#define	s/([ｘｙｚ])/\\mbox\{\\boldmath $1\}/	% \def\Vec#1{\mbox{\boldmath $#1$}}
	#	◯txt2tex:debug: % txt2tex Error:ラベル Item7 が2重に定義されてます → errorは 2重に定義・参照のときだけにする, 000723e
	#	◯機能追加: jcode.pm --> jcode.pl, 000723f
	#	◯機能追加: Put jcode.pl inside the txt2tex. 000723g
	#	◯jcode:debug: perl5.004まではjcode.plが動かないので工夫, 000723h
	#
#$VER=	'まとあと txt2tex/tex2txt 0.4, たおくま, 000707';#■□■□■□■□■□■□■□■□
	#	・・・ MacJPerl 5.1でのソフト検証 → Mac版リリース
	#	・・・ #define 英文：を完璧に, StepIdentIEEE.tex  → txt → tex のバグを撲滅
	#	◯readme.txt: Mac版リリースに向けて使い方など追加, 000707f
	#	◯txt2tex:debug: #defineの処理のバグ, 000707g
	#	◯tex2txt:debug: （）→%(%)となってしまう, 000707h
	#	○txt2tex: debug: 全角のイコール＝ → &&＝ → &＝&, 000707j
	#	○txt2tex: debug: / → \fracされない → π∞ をmojiからhensuuに変更, ＾~￣∂∇√∫∬をfracする文字に含める, 000707k
	#	 	＝G(j ω1) / {1"/"∞ + G(j ω1)} ω^* + G(j ω1)"/"∞ / {1"/"∞ + G(s)} TL
	#			↓
	#	    && ＝{\frac{G\left(j {\omega _{1}}\right)}{1/\infty  + G\left(j {\omega _{1}}\right)}} \omega ^\ast  + G\left(j {\omega _{1}}\right)/\infty  / {1/\infty  + G\left(s\right)} {T_{L}}
	#	◯tex2txt:debug: 下表のように \begin{tabular}...\end{tabular}が改行される, 000707i
	#					 if(/\"\\begin\{tabular\}\"/)  のように " を見るif文のバグ → $H_ignor='"'を定義
	#	◯txt2tex:debug: \multicolumn{1}{c ｜}{$Bp(s)$}のように  | が残る → 英文： のときもtblで｜を|に変換する,000707l
	#	    -----------------------------------------------------------------------------------------------------
	#	    |                 || \multicolumn{1}{c ｜}{$Bp(s)$} | \multicolumn{1}{c ｜}{$Ap(s)$}                |
	#	    -----------------------------------------------------------------------------------------------------
	#	    | plant           || $1.000\ s^2+0.000\ s+1.000$    |  $0.02041s^4+0.1296s^3+2.094s^2+0.7743s+1.000$|
	#	    =====================================================================================================
	#	    | \begin{tabular} ||                                |                                               |
	#	    | {@{}cc@{}} $nb$,|| $na$                           |                                               |
	#	    | \end{tabular}   || \multicolumn{1}{c ｜}{$B(s)$}  | \multicolumn{1}{c ｜}{$A(s)$}                 |
	#	    -----------------------------------------------------------------------------------------------------
	#	    | \begin{tabular} ||                                |                                               |
	#	    | {@{}cc@{}} 2,   || 4                              |                                               |
	#	    | \end{tabular}   ||                                |                                               |
	#	    |                 || $1.000\ s^2+0.0091s+1.000$     | $0.02051s^4+0.1298s^3+2.094s^2+0.7744s+1.000$ |
	#	    -----------------------------------------------------------------------------------------------------
	#	◯txt2tex:debug: \begin{document} の位置が \begin{table}の後ろになってしまう, 000707m
	#	◯txt2tex:debug: to $0 縲鰀 N$ -tuple (tex) → to $0 $\sim$ N$ -tuple (tex) → to $0 \sim N$ -tuple, 英文：時は$を追加しない 000707n
	#					 ×と\times, \bar, \geq, \cdotsも同様
	#	◯txt2tex:debug: IEEEtrans.sty に proof が既に定義されているのに\newtheorem{proof}{証明}と書いてlatex error → IEEEtransのとき、とりあえずproof はコメントする, 000707o
	#	◯txt2tex:debug: IEEEtrans.styでは\title{}, \author{} と空で\begin{abstract}だけあるときlatex error → \title{　}と全角スペース挿入, 000707p
	#	◯txt2tex:debug: $￣＾y(s)$(txt) →  $\bar {\hat y (s)$ (tex) → $\bar {\hat y (s)}$ (tex), 000707q
	#	◯tex2txt:debug: "\documentstyle... (txt) → "\documentstyle... (txt), 000707r
	#	◯txt2tex:debug: 箇条書を含むnormal時、$Ap(s)$ → $A_p(s)$, 000707s
	#	◯tex2txt:debug: 式もタブ+スペース×2+記号にして箇条書きにしてしまうことがある。→ スペースを３つ入れる, 000707t
	#	◯txt2tex:debug: タブ+スペース×3+記号を箇条書にしてしまう。 000707u
	#		Ap (s) = (s^2+2 ・ 0.25 ・ 0.7+0.7^2) "/"0.7^2 \
	#		  ・ (s^2+2 ・ 0.3 ・ 10+10^2)"/"10^2 .				← 式なのに箇条書と見なされる
	#
	#	◯txt2tex:debug: 下のミス → $$を削除, 000707v
	#		and $MAB$$=$$MB$$MP$ is nonsingular
	#			↓
	#		and ${M_{AB}}$=${M_{B}}${M_{P}}$ is nonsingular
	#	◯tex2txt:debug: $$(tex) → 削除, 000707w
	#		and $M_{AB}$$=$$M_B$$M_P$ is nonsingular
	#			↓
	#		and $MAB=MB MP$ is nonsingular
	#	◯txt2tex:debug: 下のミス。→\refの前に\があるときスペースを挿入する, 000707x
	#	◯tex2txt:debug: \ \ref{fig:stepyuki} shows → \（fig:stepyuki）showsとスペースが削除される,000707y
	#		Fig.\ \ref{fig:stepyuki} shows (tex)
	#			↓
	#		　Fig.\（fig:stepyuki）shows (txt)
	#			↓
	#		Fig.\\ref{fig:stepResp1}shows (tex)
	#	◯tex2txt:debug: ２つの行をくっつけるとき、接合される行末が,のときスペース挿入, 000707z
	#		\begin{keywords}
	#		identification,
	#		direct acquisition, 
	#		reduced order model,
	#		orthogonal determination
	#		\end{keywords}
	#			↓下のようになってしまう（ ,のあとにスペースが挿入されていない）
	#		\begin{keywords}
	#		identification,direct acquisition, reduced order model,orthogonal determination
	#		\end{keywords}
	#	◯txt2tex:debug: fracのバグ(034でOKだった), 000718a 
	#		034:OK 	 式     &	 $a = \lim\limits_{t\rightarrow \infty} \int{\frac{{\beta _{1}}\left(t\right)}{{\Phi _{a}}\left(t\right)}}$ dt     \\
	#		040:NG 	 式     &	 $a = \lim\limits_{t\rightarrow \infty} {\frac{\int \left({\beta _{1}}\left(t\right)\right)}{{\Phi _{a}}\left(t\right)}}$ dt     \\
	#	◯txt2tex:debug: "txt2tex"/"tex2txt" -> ${\frac{$txt2tex$}{$tex2txt$}}$ -> ${\frac{txt2tex}{tex2txt}}$, \frac{...}{...}の{}の中の$を削除する 000718b
	#	◯tex2txt:debug: txt2tex/tex2txt -> "txt2tex"/"tex2txt" (NG) --> "txt2tex/tex2txt" (OK) ,000718c
	#		題名：まとあと"txt2tex/tex2txt"について
	#			↓ OK
	#		\title{まとあとtxt2tex/tex2txtについて}
	#			↓ NG(tex2txt)
	#		題名：まとあと"txt2tex"/"tex2txt"について
	#			↓ NG(txt2tex)
	#		\title{まとあと${\frac{$txt2tex$}{$tex2txt$}}$について}
	#	◯txt2tex:debug: 2章：abc（4章：def）を\labelにするときと（2章：あ）を\refにするとき4や2が残る→完全削除, 000718d
	#		（4章：数値シミュレーション）
	#			↓ NG
	#		\label{4章：数値シミュレーション}
	#
#$VER=	'まとあと txt2tex/tex2txt 0.34, たおくま, 000707';#■□■□■□■□■□■□■□■□
	#	・・・ readme.txt → tex → txt でのバグを撲滅して完全形で変換する
	#
	#	◯tex2txt:debug: 0-9,(),[],｛｝だけのとき ignor処理 "..." をしない, 000601a
	#		"\date{"平成"12"年 "4"月 "19"日"("水")}"→"\date{"平成12年 4月 19日(水)"}"
	#	◯tex2txt:debug: $\LaTeX$ → "$LaTeX$" → "$"LaTeX"$", 000601b
	#	◯txt2tex:debug: LaTeX → $\LaTeX$ → \LaTeX, 000601c
	#	◯txt2tex:debug: \LaTeXの → \LaTeX の ... \aaaのあとは全角文字もくっつけるとダメなのでスペースを入れる,000611a
	#	◯tex2txt:debug: \LaTeX → "LaTeX" → LaTeX, 000604b
	#	◯tex2txt:debug: \date が 日付： にならない。 000603a
	#	◯tex2txt:debug: ピリオド. と改行の扱いを変更 000604a
	#		("kimura"@"cherry."
	#		"yyy."					→ ("kimura@cherry.yyy.or.jp")
	#		"or."
	#		"jp")
	#	◯txt2tex:debug: 下の処理がうまくいかない, 000605a
	#		#define s/\[([^\]]*)\]/\"$1\"/g
	#		#define y/０-９/0-9/
	#		#define y/ａ-ｚＡ-Ｚ/a-zA-Z/
	#	◯txt2tex:debug: cosβなど明らかにcosはcos βと空白を入れなくてもいいようにする, 000605b
	#	◯txt2tex:debug: \tabelofcontentsが\begin{document}が前 → 後に, 000605c
	#	◯main:debug: "tex"ファイル　→　TeXファイル, 000605d
	#	◯tex2txt:debug: 表のノルムの\leftなどが残っている→削除,000606a
	#	◯tex2txt:debug: 章：などのラベルの処理のバグ,000606b
	#		2章："txt2tex"のセールスポイント（章：txt2texのセールスポイント）
	#			↓
	#		2章："txt2tex"のセールスポイント
	#	◯tex2txt:debug: \inputの読み込みバグ→デバッグ＋aaa.styは読み込まない,000606c
	#		\input fancybox.sty /* ← tex2txt warning(237): 読み込みに失敗したので変換してません！*/
	#	◯tex2txt:debug: うっとうしいので下のwarningをはかない,000606d
	#		"\begin{minipage}"  /* tex2txt Warning(238):未対応のコマンドです。変でないか確認してね */
	#	◯txt2tex:debug: \begin{verbatim}...\end{verbatim}が消える！,000606e
	#	◯tex2txt:debug: \end{verbatim}\end{verbatim}\end{ovalboxFrame}→\end{verbatim}\end{ovalboxFrame},000606f
	#	◯tex2txt:debug: 表の\fracが残る→修正,000609a
	#		==============================================================
	#		| 式    || a = "lim"_{t→∞} ∫ {\frac {β1(t)}{Φa(t)}} "dt"|
	#		--------------------------------------------------------------
	#	◯tex2txt:debug: 行列の括弧が変→修正,000609b
	#		a = ／x ＼ + (a- ／a1 , 0  , …  , 0  ＼ + ／x , 1 ＼^{-1} ) - a        （eqn:2）
	#		    ＼y ／       | a2 , a1 , ・. , 0   |   | 2 , 3  |
	#		                 ＼： , ： , ・. , 0   |   | z , 9 ／
	#		                 ＼an , am , …  , a1 ／
	#	◯tex2txt:debug: 行列の要素が消えてカッコがずれる→修正,000609c
	#		／Pv  ＼  ∝  ／    , 1/2         ＼  ／窶磨P~a窶磨〟_"/" 3 π       （, (中）
	#		＼Xv2 ／      ＼MP2 , √ ＾a! ／  ＼｜＾α｜  ／
	#			↓
	#		／Pv ＼  ∝ ／MP^b , 1/2     ＼  ／窶磨P~a窶磨〟_ / 3π	（,(中）
	#		＼Xv2／     ＼MP2  , √{＾a!}／  ＼｜＾α｜  ／
	#	◯tex2txt:debug: "\verb"｜"\vspace{1zw}"｜ → \verb!\vspace{1zw}!,000611b
	#					"\verb|"”””"|" → \verb!"”"!
	#	◯tex2txt:debug: のように"$/$"を → のように"/"を, 000611c
	#	◯tex2txt:debug: √ ＾a!  → √{＾a!}, 000612a
	#	◯tex2txt:debug: \# (tex) → "\"#  (txt) → #, 000612b
	#	◯txt2tex:debug: #  (txt) → \# (tex) , 000612c(000530h,00430a)
	#	◯txt2tex:debug: 1) → $1  )$ ... 1 と ) 間にスペースが入る(000530gの責),000613a
	#	◯tex2txt:debug: （）(tex) →  () (txt) → （）,000623a
	#	◯tex2txt:debug: &=& → = とする記号を txt2tex とそろえる, 000623b
	#	◯tex2txt:debug: 表・・・下のバグを修正, 000623c
	#		"\begin{flushright}"
	#		"\begin{flushleft}"
	#		\begin{verbatim} ...
	#		\end{verbatim}
	#		表：
	#		---------------------------------------------------------------------------
	#		| 機能                                |  LaTeX コマンド                   |
	#		===========================================================================
	#		| 改行(式，題名，章題，箇条書で有効)  | "\verb|"                          |
	#		| "|"                                 |                                   |
	#		| 改ページ                            | "\verb" ｜"\clearpage" ｜         |
	#		| 右寄せ                              | "\verb|..."                       |
	#		| ...                                 |                                   |
	#		| "\end{flushright}|"                 |                                   |
	#		| 左寄せ                              | "\verb|..."                       |
	#		| ...                                 |                                   |
	#		| "\end{flushleft}|"                  |                                   |
	#		|  [A タリング                        | "\verb" ｜"\centering" ｜         |
	#		| 1段組                               | "\verb" ｜"\onecolumn" ｜         |
	#		| 2段組                               | "\verb" ｜"\twocolumn" ｜         |
	#		---------------------------------------------------------------------------
	#		| 横罫線                              | "\verb" ｜ ｜                     |
	#			↓ (上が誤，下が正)
	#		表：
	#		------------------------------------------------
	#		|機能	|LaTeXコマンド		|
	#		============	====================================
	#		|改行(式，題名，章題，箇条書で有効)	|\verb!\\!		|
	#		|改ページ			|\verb!\clearpage!		|
	#		|右寄せ				|\verb!\begin{flushright}...\\...\end{flushright}!	|
	#		|左寄せ				|\verb!\begin{flushleft}...\\...\end{flushleft}!	|
	#		|センタリング		|\verb!\centering!	|
	#		|1段組				|\verb!\onecolumn!	|
	#		|2段組				|\verb!\twocolumn!	|
	#		|横罫線				|\verb!\hline!	|
	#	◯txt2tex:debug: \title{txt2texについて, \author{くま, など } が付かない, 000625a
	#	◯tex2txt:debug: 図のファイル名は省略不可なのに省略していた。000625b
	#	 	図："txt2tex"の広がり（fig_ex1, 0.6倍）
	#				↓
	#		図："txt2tex"の広がり（fig_ex1.eps, 0.6倍）
	#	◯tex2txt:debug: \end{minipage} (TeX) → "\end{minipage} (txt) → "\end{minipage}" (txt), "のミス, 000625c
	#	◯tex2txt:debug: }{ → } { とスペースを挿入してしまう, 000625d
	#		 \newenvironment{ovalboxFrame}{\begin{Sbox}
	#				↓
	#		"\newenvironment{ovalboxFrame} {\begin{Sbox}"
	#	◯txt2tex:debug: ignorとfracのバグ→""の中に\beginがあってかつ、右隣に/があるとき "..." .../...とスペース挿入, 000625e
	#		　"\begin{shadowboxFrame}"a/b
	#				↓
	#		${\frac{$\begin{shadowboxFrame}$a}{b}}
	#	◯txt2tex:debug: \hat{...}と中カッコ{}が付かないことがある, 000625f
	#		OK: a^~b/c_＾(a(t)+b(t))
	#		NG: (a^~b)/(c_{＾(a(t)+b(t))}) ... \hat \left(... となって latex error となる
	#
	#	◯txt2tex:debug: \max → maxにしてしまう, 000625g
	#		∴ "d"y/"dt"=\dot{y} ≠ \max_i (a, b)	（eqn:7）
	#	○txt2tex:debug: \mbox {\”E} (txt) → \mbox{\$"$E} (tex)(\$となりerror, \ $"$EもЁにならない) → \mbox{\"E}, 000625h
	#						”を$の中でも外でもどちらでもいい文字に変更する
	#
	#	◯tex2txt:debug:   \mbox{\"{E}} (tex) → \mbox {\”E} (txt) → Ё, 000625i
	# 	○txt2tex:debug: \$ を無変換にする, 000625j
	#	◯txt2tex:debug: \~ (txt) → \$\tilde{}$ (tex) → \~, 000625k
	#	◯tex2txt:debug: \~ (tex) → \"~" (txt) → "~", 000625l
	#	×txt2tex:debug: 式の中の\mbox{...}の中を dollar 処理する, 000625m（やめ→000625nで代用）
	#				式の中の\mbox{例\vdots　あああ（{i_{t}} &:& 1）} → \mbox{例$\vdots$　あああ（${i_{t}}$:1）}
	#	◯txt2tex:debug: \mbox{...}を ignor化, 000625n
	#	◯tex2txt:debug: 行の順番が入れ替わってしまう, 000625o
	#		\clearpage  % ← 改ページコマンドです。
	#		\tableofcontents
	#		\clearpage  % ← 改ページコマンドです。
	#			↓
	#			目次：
	#		"\clearpage"
	#		　"\clearpage"
	#	◯tex2txt:debug: 改行（空行）＋\begin{tabular} → 改行を無視してしまう, 000625p
	#			これを修正すると改行でないのに改行してしまう...タブ＋\beginを分解→タブの行が空行と同じく改行の意味, 000625q
	#			これを修正すると行列のカッコにタブが含まれてカッコがずれるので修正, 000625r
	#	◯tex2txt:debug: \LaTeX (tex) → "LaTeX" (txt) → LaTeX, ... LaTeXは""で囲まない 000625s
	#		txt2tex,\ \LaTeX ,\ dvips,\ gvなど
	#			↓
	#		"txt2tex,  LaTeX  , dvips, gv"など
	#	○tex2txt:debug: （ラベル）(tex) → （ラベル）(txt:bug) → "（ラベル）"(txt), 七夕000707a
	#		(元txt)  参照ラベルは、”"章：はじめに（ラベル）"”のとき、"（ラベル）章"と書くと1章となる。
	#		(元tex)参照ラベルは、"章：はじめに（ラベル）"のとき、（ラベル）章と書くと$1$章となる。
	#			↓bug
	#		(新txt)　参照ラベルは、”章：はじめに（ラベル）”のとき、（ラベル）章と書くと1章となる。
	#		(新tex)参照ラベルは、"章：はじめに\ref{ラベル}"のとき、\ref{ラベル}章と書くと$1$章となる。
	#	○tex2txt:debug: 式の中の：→"：" (\vdotsを避ける）,000707b
	#		(元txt)	"\#define 英文："
	#		(元tex)	&& \#define 英文：
	#			↓
	#		(新txt)	#"define"  英文：	→	#"define"  英文"："
	#		(新tex)	&& \#define 英文\vdots
	#	○tex2txt:debug: 箇条書中に% 外字"①"は表示と印刷ができないかも？を出力して、タブなし改行してしまうので、箇条書番号が1にリセットされる,000707c
	#	    |	　Item2: % 外字"①"は表示と印刷ができないかも？
	#		|行頭に”タブ”、続いて、アルファベット...
	#		|	　Item3: 続いて箇条書の本文、続いて...
	#	○tex2txt:debug: ,\ (tex)→ ", " (txt) → , (tex) と'\ 'が削除されてしまう→ , を""の中に入れない,000707d
	#		(元txt)	  ・"txt2tex", LaTeX, "dvips", "gv"などのランチャー作成
	#		(元tex)	$\cdot$ txt2tex,\ \LaTeX ,\ dvips,\ gvなどのランチャー作成
	#			↓
	#		(新txt)	　・ "txt2tex, " LaTeX " , dvips, gv"などのランチャー作成
	#		(新tex)	$\cdot$  txt2tex,  \LaTeX  , dvips, gvなどのランチャー作成
	#	○tex2txt:debug: ｝→\}→"｝", texファイルにαなどあると、"α"とする。000707e
	#	｝・○●◎○◇□△▽☆★●◆■▲◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤ・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・ ・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・です。
	#			↓
	#	\}$\cdot$ $\bigcirc$ ●◎$\bigcirc \Diamond \Box \bigtriangleup \bigtriangledown \star$ ★●◆■▲◎$\bigcirc \bigcirc$ ①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳${\expandafter\uppercase\expandafter{\romannumeral 1}} {\expandafter\uppercase\expandafter{\romannumeral 2}} {\expandafter\uppercase\expandafter{\romannumeral 3}} {\expandafter\uppercase\expandafter{\romannumeral 4}} {expandafter\uppercase\expandafter{\romannumeral 5}}$
	#
	#
#$VER=	'まとあと txt2tex/tex2txt 0.33, たおくま, 000530';#■□■□■□■□■□■□■□■□
	#	◯txt2tex:機能追加: 下記perlコマンドを直接使えるようにする, 000530a
	#		 #define	s/^○/節：/
	#		 #define	s/ＩＰＭ/"IPM"/g
	#		 #define	y/。、/．，/
	#	◯txt2tex:debug: ：A → \vdotsA となり \vdotsとAがくっつく -> 間にスペースを入れる, 000530b
	#	◯txt2tex:debug: 文頭に\clearpageなどがあると \begin{document}の位置がずれる, 000530c
	#		\clearpage
	#		章：　基本特許（トリップレス＋圧縮機）
	#	◯txt2tex:debug: % txt2tex Error():図のepsファイル名が明記されてません。 ・・・行番号が表示されていない,000530d
	#	◯txt2tex:debug: % txt2tex Warning(27): カッコが")("のように開いています。・・・→ = \rightarrow もカッコとみなして警告している,000530e
	#	◯txt2tex:debug: \left｛ と全角が残っている→ \left\{に変更,000530f
	#	◯txt2tex:debug: {\frac{1}{s \right)}} と{}の中に\right)が入っている→{\frac{1}{s}} \right)と外に出す,000530g
	#		原因：(1,1/s)→/*1*/1,1/s/*2*/→21,1/s3→21,\frac{1}{s3}→(1,\frac{1}{s)}
	#		対処：カッコを/*1*/とするとき両サイドに" "を入れる
	#
	#	◯txt2tex:debug: # はlatex errorになる（$#$も）→ \# に変換する,000530h
	#	◯仕様変更: 字が紙からはみだす→ a4j.styをデフォルトで使う,000530i
	#	◯txt2tex:debug: tableの中の"　"を無くす（表の大きさがかわってしまう）,000530j
	#	◯txt2tex:debug: ラベル以外の"（"aaa"）→（a_{aa}）となってしまう,000530k
	#
#$VER=	'まとあと txt2tex/tex2txt 0.32, たおくま, 000529';#■□■□■□■□■□■□■□■□
	#	・・・ StepIdentSice.tex → txt → tex でのバグを撲滅して完全形で変換する
	#
	#	◯txt2tex:debug: get_BEGINNINGで \authorlist も \author とみなすため行頭に % を足してしまう, 000527a
	#	◯新機能: 行列で"(中"を指定したいが、式番号を付けたくないとき、（欠番：,(中）とかく, txt2tex:000527b, tex2txt:000527c
	#		debug:式の後ろに（,中）とあると、\nonumberを付けないため式番号が付いてしまう
	#	◯新機能: 行列の改行 M=[... \n ...] を書けるようにする, txt2tex:000527d, tex2txt:000527e
	#	◯tex2txt:debug: 行列の行の最終の文字 0 が消える, 000528a
	#	◯txt2tex:debug: \begin{thebibliography}{99}の前に、空行がないと、異常に前の段落の行間が詰まる, 000528c
	#	◯tex2txt:debug: (B.10)式 eqn:def_xiBP の && の位置が変わってしまっている（次縦ベクトルの上）, 000529a
	#			&& の位置情報を活かす(もとの位置とずれるのを防ぐ)
	#		零行列である。の上の式(B.13) eqn:xiA-xiBP
	#		次縦ベクトルである。の下の式(B.16) eqn:def:[M_B;M_B2]
	#		(B.23) 
	#			↓
	#		&& a_1 = b_1 → && a1 = b1 のように && を残す
	#	◯tex2txt:debug: 字下げ行の上に表があると、改行の字下げがされない(StepIdentSice.texのEulerの次の行), 000529b
	#		零行列である。の後, 000529c
	#
#$VER=	'まとあと txt2tex/tex2txt 0.31, たおくま, 000524';#■□■□■□■□■□■□■□■□
	#	・・・tex2txt:機能追加: txt2tex.pl 0.22 以降の新機能に対応させる
	#
	#	◯tex2txt:仕様統一: 図の書き方変更m 000522a
	#		図：キャプション（ラベル,file=ファイル名） ... file = ファイル名.eps
	#			↓
	#		図：キャプション（ラベル,filename.eps,上下ここ頁,1.0倍） ... キャプション省略時\begin{figure}[t]なし
	#	◯tex2txt:仕様統一: 表の書き方追加, 000522b
	#		表：キャプション ... 参照は、（表：キャプション）
	#			or
	#		表：キャプション（ラベル） ... 参照は、（表：ラベル）
	#		表：キャプション（ラベル,上下ここ頁,中左右） ... キャプション省略時\begin{table}[t]なし
	#	◯tex2txt:仕様統一: 行列の書き方（ラベル, (中）を変更, 000523a
	#	◯tex2txt:仕様統一: 。、→．，を止める, 000524a
	#	◯tex2txt:仕様統一: 箇条書きも（...）をラベルとして使う, ←既に対応済み
	#	◯tex2txt:仕様統一: Ⅵなども変換する, ←既に対応済み（ただし[ 	]+を含むときに未対応）
	#	◯tex2txt:仕様統一: #define	英文：　のとき$$を外さず、$の中だけ下付きや分数処理する, 000524b
	#	◯tex2txt:機能追加: texファイルが英文かどうか判定して英文ならば#define	英文： とかく, 000524c
	#	◯main:機能追加: オプション -e, -j 追加（強制的に英文，和文としてtex2txtする）, 000524d
	#
#$VER=	'まとあと txt2tex/tex2txt 0.30, たおくま, 000520';#■□■□■□■□■□■□■□■□
	#	・・・ StepIdentSice.texのオリジナル→ txt → tex でのLaTeX errorをとる．
	#	◯main:debug: file.texが既にあっても上書きされる→file_1.texに出力する, 000508a
	#	◯txt2tex:debug: a4j.styを外して、\setlength{\headheight}などで対処する, 000508b
	#	◯tex2txt:debug: \setlength{\headheight}などとbecause.styの内容(\def\because ...)を削除する, 000509a
	#	◯txt2tex:debug: && が１行に２つつく, 000509b
	#	◯txt2tex:debug: a1^(2)→{a_{1}}^\left(2\right)→{a_{1}^{\left(2\right)}}, 000510a
	#	◯txt2tex:debug: txt2texのバグ？ Ｃが残ってて変かも？, 000510b
	#	◯txt2tex:debug: simotuki新規書き直し, 000510c
	#	◯txt2tex:debug: )( -> $\right)\left($ ... latex error -> $)($, 000510d
	#	◯tex2txt:debug: txt2texでの図：の仕様変更を反映, 000511a
	#	◯tex2txt:debug: \def \therefore{ ... のとき、１行まるごと""で囲む(txt2texすると\def $therefore${... になっていた),000511b
	#	◯tex2txt:debug: （参:"step-PE-1"）-> （参："step-PE-1"）, 000511c
	#		参考文献のラベルバグ，\cite{参:step-PE-1}→（参:参:"step-PE-1"）を（参：参:"step-PE-1"） に修正
	#		参：参:ident-period)足立：ユーザのためのシステム同定理論;計測自動制御学会図書, "pp. "~"84--85, (1994)"
	#	◯tex2txt:debug: 箇条書きの中に式がある時空行をつくるとA1,A2,A1と、箇条書き番号が分断される→このとき空行をつくらない, 000511d
	#	　A1: Ap (s)は安定多項式．  （"A:2StepIdent"）  　A2: 安定な伝達関数  Up (s)
	#	◯tex2txt:debug: {\bar u_{p}} -> {￣up} -> ￣up, 000512a
	#		・下付き処理の手直し, 000515a
	#		・{ { {( Bp (s))/( Ap (s))} } } -> ( Bp (s))/( Ap (s)), 000515b
	#			{s^N Kp X2 (s) { { {(U(s))/( Ap (s) A(s))} } } } -> {s^N Kp X2 (s) {(U(s))/( Ap (s) A(s))} }は未
	#		・_{}, ^{}以外の{}を削除, 000515c 
	#			\hspace -3"mm" となるのを避ける, 000515d
	#			入れ子{{...}} は {...}のように残る
	#
	#	◯txt2tex:debug: 10 -> $1, 000514a
	#		while(length($_)>0) <- while($_)では 0 を''とみなすようだ
	#	◯tex2txt:debug: (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g, 000516a
	#	◯tex2txt:debug: \right｝, \right\}が残っている。, 000516b
	#	  "lim"_{t→\ ∞} \ {∫_0^t} ｛ y(τ)\ -\ ＾y(τ)\right｝ (d τ)^k
	#	◯tex2txt:debug: 行列だけでなく式のときも \vdots→：, \ddots→.・に変換する, 990107e, 000517a
	#		\ddots→.・を・.に変換する
	#
	#		"\begin{center}"\n \vdots → "\begin{center}"：  
	#		式の中の \vdots → ：
	#	◯tex2txt:debug: 定理：ラベルの書き方ミス: 000517b
	#定理1：
	#　"\label{"定理："StepIdent}"　
	#		↓
	#定理1："StepIdent" と書いて、\ref{StepIdent}は（定理1："StepIdent"）とする。
	#	◯tex2txt:debug: 表：に\centeringがあると書かない, 000517c
	#	表：A(s) "and "B(s)
	#	"\centering"	（tbl:resultAB）
	#	◯tex2txt:debug: 表：の＆を&にする, 000517d
	#	◯tex2txt:debug: 表：のとき\multicolumn{｜c｜}を\multicolumn{|c|}にする←悪かったのはabs_norm_tex2txt, 000517d
	#	◯main:debug: \input の txt2tex ../file.tex のときの対応, 000519a
	#	◯txt2tex:debug: ( Bp (s))/( Ap (s)) → \frac{(Bp(s))}{Ap(s)}と分子の()が残る, 000519b
	#	◯txt2tex:debug: ・. → \cdot .→ \ddots, 000519c
	#	◯tex2txt:debug: 章名とラベル名が同じとき、ラベルを省略する, 000519e
	#		4章：数値シミュレーション（4章：数値シミュレーション） → 4章：数値シミュレーション
	#
	#	◯tex2txt:debug: tex2txt fatal error(1131):$_connect_kakko_1gyou ... が出てしまった! → ] があるとこうなる!, 000520a
	#	◯tex2txt:debug: 多項式 ${X_{2}}$ → 多項式  X2 → 多項式 X2 とスペースを増やしていた → 不要なスペースを削除, 000520b
	#	◯tex2txt:debug: 左中カッコのみの行列がふつうの行列になっている, 000520c
	#     = ／0           , ， k ≦ N  ＼    （eqn:y-yhat=0）
	#       | Kp \ X2 (0) , ， k=N+1    |
	#       ＼∞          , ， k ≧ N+2／
	#	◯tex2txt:debug: 定理1："StepIdent"　→ "　"を改行する, 000520d
	#		\newtheorem{theorem}{定理}
	#		\begin{theorem}
	#		 \label{定理：StepIdent}%990123
	#		　
	#		\end{theorem}
	#	◯tex2txt:debug: (（eqn:"Ap"(s)）) → （eqn:"Ap"(s)）, 000520e
	#	(\ref{eqn:y=Gu})$\sim (\ref{eqn:Ap(s)}),(\ref{eqn:def:U(s)}),$(\ref{eqn:def:pi})式より${p_{1}} $は次式で与えられる．
	#		↓
	#	　（"eqn:y=Gu"）縲鰀 (（eqn:"Ap"(s)）),(（eqn:"def":U(s)）),（"eqn:def:pi"）式よりp1は次式で与えられる．
	#		↓
	#	　（"eqn:y=Gu"）縲怐ieqn:"Ap"(s)）,（eqn:"def":U(s)）,（"eqn:def:pi"）式よりp1は次式で与えられる．
	#	◯txt2tex:debug: ,\  → $,\$ → $,\ $, 000520f
	#	◯tex2txt:debug: $,(\ref{eqn:def:[M_P;M_P2]}),$ → ,\ （${e_{qn}}$:${d_{ef}}$: $\left[{M_{P}} \right.$ ;$M_{P_{2}} ]$ ）$,\ $ → （"eqn:def:[M_P;M_P2]"）, 000520g
	#	◯tex2txt:debug: 000520gでは不十分（"eqn:def:[M_B";"M_B2]"） → （eqn:def:[M_B;M_B2]）, 000520h
	#		1. （，）→(, ) に変換
	#		2. \ref{...}→（...）に変換
	#		3. （...）の...はdollarなどしない
#-------------------------------------------------------
############		Version 履歴(end)		############
#-------------------------------------------------------


#main(begin)
#&set_perl_ver;	#うまく機能しないので使わない
&read_matoatorc; # $MATOATORC_PATHが存在しないため機能しない（コメントアウトしてもよい？）
&set_OS;
&set_H_RM; # OSによって変数の変更
&shori_hikisuu; # 
#main(end)
exit;	# 何故かわからないけど必要! 000507





###### Swich jperl5 or perl580, begin
sub set_perl_ver{#うまく機能しないので使わない
	my	($tmp);

	#--- perl のヴァージョンを取得 begin
	if($H_PERL_VER!=2&&$H_PERL_VER!=1){
		$H_PERL_VER=0;	# 1:jperl5, 2:perl580以降, 0:else
		open(TMP,"jperl -v|");
		# system 'jperl -v>txt2tex0.tmp';	open(TMP,"<txt2tex0.tmp");
		while(<TMP>){	if(/jperl5/){	$f=1;}}close(TMP);
		if($H_PERL_VER==0){	open(TMP,"perl -v|");	while(<TMP>){
			if(/This is perl, v([5-9])\.([0-9])/){
				if($1>5||($1==5&&$2>=8)){
					$H_PERL_VER=2;
				}
			}
		}}
		close(TMP);
	}
	#--- perl のヴァージョンを取得 end

	if($H_PERL_VER==2){
	#	eval 'use encoding "utf8", STDOUT=>"shift-jis";';	#perl580
	#	eval 'use encoding "utf8";';	#perl580
	#	$tmp='use encoding "utf8", STDOUT=>"shift-jis";';eval $tmp;	#perl580
	#	eval "use encoding \"utf8\", STDOUT\=\>\"shift\-jis\";";	#perl580

		# eval {use encoding "utf8", STDOUT=>"shift-jis";};	#perl580
		# eval 'use Encode qw/ from_to /;';
		# eval 'use open ":utf8";';

		# use encoding "utf8", STDOUT=>"shift-jis";
		# use Encode qw/ from_to /;
		# use open ":utf8";
	}else{
	#	eval 'use Dummy';
	}
}
###### Swich jperl5 or perl580, begin


#************************************************************************
#************************************************************************
# %perl txt2tex.pl -h file.txt の引数に対する処理．入出力ファイルの設定 (begin) 000410a
#************************************************************************
#************************************************************************
sub	shori_hikisuu{
	$H_eibun=-1;	#000524d

	# &set_H_RM;
	if( $#ARGV <= -1 ){			# 引数なしのとき
		&print_help;
	}elsif( $#ARGV  >= 2 ){		# 引数3つ以上のとき
		&print_help;
		&print_("\n".'*****  んっ！： 引数が多すぎです． *****'."\n");
	}elsif( $#ARGV == 0 ){		# 引数1つのとき
		if( $ARGV[0] =~ /^\-/ ){	# 第１引数が -h など先頭が - を含むとき /^-/でも同じ？
			if( $ARGV[0] eq '-h' ||			# 第１引数が -h or -\?
				$ARGV[0] eq '-?' ){
				&print_help;
			}elsif( $ARGV[0] eq '--tex2txt' ||	# 第１引数が --tex2txt
					$ARGV[0] eq '-e' ||			# 第１引数が -e	#000524d
					$ARGV[0] eq '-j' ){			# 第１引数が -j
				&print_help;
				&print_("\n".'*****  んっ！： ファイル名が指定されてません． *****'."\n");
			}elsif( $ARGV[0] eq '--txt2tex' ){	# 第１引数が --txt2tex
				&print_help;
				&print_("\n".'*****  んっ！： ファイル名が指定されてません． *****'."\n");
			}elsif( $ARGV[0] eq '--help' ){		# 第１引数が --help
				&print_readme;
			}elsif( $ARGV[0] eq '--fig_ex1.eps' ){	# 第１引数が --fig_ex1.eps
				&print_fig_ex1_eps;
			}elsif( $ARGV[0] eq '--CELsty'){	# 第１引数が --CELsty 200701
				&print_ControlEngineeringLab;
			}elsif( $ARGV[0] eq '--ANNUALsty'){	# 第１引数が --ANNUALsty 200701
				&print_Annual;
			}elsif( $ARGV[0] eq '--install' ){	# 第１引数が --install
				&install;
			}else{
				&print_help;
				&print_("\n".'*****  んっ！： 未対応のオプションです。 *****'."\n");
			}
		}elsif( $ARGV[0] =~ /\.tex/ ){
			$H_INPUT_FILE = $ARGV[0];
			&set_output_file('.txt');	# 出力ファイルの設定

			&tex2txt;				# 拡張子が tex のとき
		}else{
			$H_INPUT_FILE = $ARGV[0];
			&set_output_file('.tex');	# 出力ファイルの設定

			&txt2tex;				# 拡張子が tex 以外のとき
		}
	}elsif( $#ARGV == 1 ){		# 引数2つのとき
		$H_INPUT_FILE = $ARGV[1];

		if($ARGV[0] eq '--tex2txt' ||		# 第１引数が --tex2txt
		   $ARGV[0] eq '-e' ||				# 第１引数が -e	#000524d
		   $ARGV[0] eq '-j' ){				# 第１引数が -j
			if(		$ARGV[0] eq '-e' ){	$H_eibun=1;}	#000524d
			elsif(	$ARGV[0] eq '-j' ){	$H_eibun=0;}
			&set_output_file('.txt');	# 出力ファイルの設定

			&tex2txt;
		}elsif( $ARGV[0] eq '--txt2tex' ){	# 第１引数が --txt2tex
			&set_output_file('.tex');	# 出力ファイルの設定

			&txt2tex;
		}elsif( $ARGV[0] eq '--txt2unix' ){	# 第１引数が --txt2unix
			&txt2unix;
		}elsif( $ARGV[0] eq '--txt2dos' ){	# 第１引数が --txt2dos
			&txt2dos;
		}elsif( $ARGV[0] eq '--txt2mac' ){	# 第１引数が --txt2mac
			&txt2mac;
		}elsif( $ARGV[0] eq '--h2z' ){		# 第１引数が --h2z
			&h2z;
		}elsif( $ARGV[0] eq '--dvi' ){		# 第１引数が --dvi
			&dvi;
		}elsif( $ARGV[0] eq '--html' ){		# 第１引数が --html
			&html;
		}elsif( $ARGV[0] eq '--ps' ){		# 第１引数が --ps
			&ps;
		}elsif( $ARGV[0] eq '--pdf' ){		# 第１引数が --pdf
			&pdf("a4");
		}elsif( $ARGV[0] eq '--pdfa5' ){		# 第１引数が --pdfa5
			&pdf("a5");
		}elsif( $ARGV[0] eq '--pdfpv'){		# 第１引数が --pdfpv # 200624
			&latexmk("-pv");
		}else{								# それ以外
			&print_help;
			&print_("\n".'*****  んっ！： 引数が2つになるのは，第一引数が --tex2txt, --txt2tex, --txt2unix, --txt2dos, --txt2mac, --h2x のときだけです． *****'."\n");
		}
	}
}

sub set_H_RM{
	if( $H_OS eq 'MS-Windows' ){	# MS-Winの場合 旧
		$H_RM = "del";	$H_CP = "copy";	$H_LS = "dir";	$H_CAT = "type";	$H_MV = "move";	$H_CSH = ""; # $H_MVをrenからmoveに変更 200701
	}elsif( $H_OS eq "MSWin32" ){	# Windowsの場合 新 200801
		$H_RM = "del";	$H_CP = "copy";	$H_LS = "dir";	$H_CAT = "type";	$H_MV = "move";	$H_CSH = "";	$H_JCODE2 = "cp932";	$H_NL = "\n";
	}elsif( $H_OS eq "darwin" ){	# Macintoshの場合 200801
		$H_RM = "rm";	$H_CP = "cp";	$H_LS = "ls -Fl";	$H_CAT = "cat";	$H_MV = "mv";	$H_CSH = "";	$H_JCODE2 = "utf8";	$H_NL = "\r\n";
	}else{
		print("Eroor!!\nPlease cheak OS name\n");
		exit;
	}
	if($H_OS eq "MSWin32"){
		binmode(STDIN,":encoding(cp932)") ;		# 標準入力は，SJIS
		binmode(STDOUT,":encoding(cp932)") ;	# 標準出力は，SJIS
		binmode(STDERR,":encoding(cp932)") ;	# 標準エラーも，SJIS
		@ARGV = map { decode('cp932',$_) } @ARGV ;	# コマンド引数をutf8とする。"/$pat/"のため @array1=map{equation(using $_)}@array;で@arrayの要素をequationに沿って変換を行い、@array1に格納する decodeで外部文字列を内部文字列に変換
	}elsif($H_OS eq "darwin"){
		binmode(STDIN,":utf8") ;		# 標準入力は，SJIS
		binmode(STDOUT,":utf8") ;		# 標準入力は，SJIS
		binmode(STDERR,":utf8") ;		# 標準入力は，SJIS
	}
}

	########################################################
	# インストールスクリプト begin		000813a
	#	jperl matoato --install
	########################################################
sub	install{
	my	($perl_path);
	&get_OS;							# OSの取得
	&set_H_RM;
	$perl_path = &get_jperl_path;		# jperl のパス取得
	if( $H_OS eq 'Linux' ){				# Linuxの場合

		&write_cshrc;					# 	matoato のパスを.cshrcに書く
		&write_matoato($perl_path);		#	jperl, .matoatorc のパスと$H_OSをmatoatoの先頭数行に書く
	}elsif( $H_OS eq 'MS-Windows' ){	# MS-Winの場合
		# &write_autoexec;				# 	matoato.bat のパスをautoexec.batに書く
		# &write_matoato($perl_path);		#	jperl, .matoatorc のパスと$H_OSをmatoatoの先頭数行に書く
		if($H_PERL_VER==1){
			# open(TMP_IN,"<matoato.pl");	open(TMP_OUT,">matoato.jpl5");
			# while(<TMP_IN>){
			# 	if(1<=$. && $.<=1){	s/^\#//;}	print TMP_OUT;
			# }
			# close(TMP_IN);	close(TMP_OUT);
			# open(TMP,$H_CP." matoato.jpl5 matoato.pl|");	close(TMP);
			&pl2bat_matoato;				# 	matoato → matoato.batに変換
		}elsif($H_PERL_VER==2){
			# open(TMP,'piconv -f "euc-jp" -t "utf8" matoato.pl>matoato.pl58'."|");	close(TMP);
			# open(TMP_IN,"<matoato.pl58");	open(TMP_OUT,">matoato.pl");
			# while(<TMP_IN>){
			# 	if($. <= 2){	$_='#'.$_;}
			# 	if(6<=$. && $.<=9){	s/^\#//;}	print TMP_OUT;
			# }
			# close(TMP_IN);	close(TMP_OUT);
			# open(TMP,$H_RM." matoato.pl58|");	close(TMP);
			# open(TMP,"pl2bat matoato.pl|");	close(TMP);
			# open(TMP,">matoato.bat"); #200624 openの引数は３つが推奨
			open(TMP,">","matoato.bat"); # matoato.batはMSのバッチファイル。printの内容を書き込む
			print TMP '@rem = \'--*-Perl-*--'."\n";
			print TMP '@echo off'."\n";
			print TMP 'if "%OS%" == "Windows_NT" goto WinNT'."\n";
			print TMP "perl ".$perl_path."\\matoato.pl %1 %2 %3 %4 %5 %6 %7 %8 %9"."\n";
			print TMP 'goto endofperl'."\n";
			print TMP ':WinNT'."\n";
			print TMP "perl ".$perl_path."\\".'matoato.pl %*'."\n";
			print TMP 'if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl'."\n";
			print TMP 'if %errorlevel% == 9009 echo You do not have Perl in your PATH.'."\n";
			print TMP '@rem \';'."\n";
			close(TMP);
			open(TMP,$H_CP." matoato.pl ".$perl_path."|");	close(TMP); # open(TMP,"copy matoato.pl %APBDRIVE%\tex\matoato.pl|") "copy...\matoato.pl"を実行し、TMPに渡す
		}
		open(TMP,$H_CP." matoato.bat ".$perl_path."|");	close(TMP);
		open(TMP,$H_RM." matoato.bat|");	close(TMP); # open(TMP,"del matoato.bat|")
	}
}

	########################################################
	# OSとperlのバージョンの取得
	########################################################
sub	get_OS{
	$H_OS='';
	my $H_PERL_VER=0;
	open(OS,"perl -v|");
	while(<OS>){
		chop;
		if( /MSWin/ ){
			$H_OS = 'MS-Windows';	$H_JCODE='sjis';
		}elsif( /linux/ || /bsd/ ){
			$H_OS = 'Linux';		$H_JCODE='euc';
		}
		if(/This is perl[^0-9]*([5-9])\.([0-9])/){
			if($1>5||($1==5&&$2>=8)){
				$H_PERL_VER=2;
			}
		}
		if(/jperl5/){	$H_PERL_VER=1;}
	}
	close(OS);

	if($H_PERL_VER==0){
		print_("\n------インストールできません-----\n\tjperl5または perl5.8.0以降を先にインストールしてください。あしからず。\n");
		exit;
	}
	if( $H_OS eq '' ){
		print_("\n------インストールできません-----\n\t未知のOSです。あしからず。\n");
		exit;
	}
}

	########################################################
	# jperl のパスチェック
	#	jperl のインストールとそのパスをチェックし、パスを返す
	########################################################
sub	get_jperl_path{
	my	($f, $path);
	if($H_OS eq 'MS-Windows'){
		open(PERL,"path|");
		$path = '';
		while(<PERL>){
			chop;
			if( /([^=;]*\\[pP][eE][rR][lL]\\[bB][iI][nN][^;]*)/ ){
				$path = $1;
			}
		}
		close(PERL);
		# $path =~ s/[^\/]*$//;
		# $path =~ s/\//\\/g;
	}else{
		open(PERL,"which perl|");
		$path = '';
		while(<PERL>){
			chop;
			if( /\/perl/ ){
				$path = $_;
			}
		}
		close(PERL);
	}
	return($path);	#	$pathを返す
}

	########################################################
	#	matoatoの#!/usr/bin/jperl -Leucのパス修正と、$H_OS追加
	########################################################
sub	write_matoato{
	my	($path, $f);
	$path = $_[0];
	# #!/usr/bin/jperl -Leuc
	# $H_OS = 'MS-Windows';	$H_JCODE = 'sjis';	#---- OS, 日本語コードの設定

	open(TMP,">iran.tmp");
	print TMP '#!'.$path." -Leuc\n";
	print TMP '$MATOATORC_PATH = '."\'".$MATOATORC_PATH."\';\n";
	print TMP '$H_OS='."\'".$H_OS."\'".';	$H_JCODE='."\'".$H_JCODE."\';\n";
	# if( $H_OS=~/MS-Win/){
		# print TMP 'use Win32::Registry;'."\n";
		## print TMP 'use Cwd;'."\n";
		## print TMP 'use Config;'."\n";
		## print TMP 'use Archive::Tar;'."\n";
	# }
	# platex -v  -> (SJIS) -> $H_OUT_CODE にしようかな。
	close(TMP);

	open(TMP,">>iran.tmp");	open(TXT2TEX,"<matoato");
	$f=0;
	while(<TXT2TEX>){
		if(/\# The above lines are changed/){	$f=1;}
		if( $f==1 ){	print TMP;}				# 約3行目以降をコピー
	}
	close(TXT2TEX);	close(TMP);

	open(TMP,"<iran.tmp");	open(TXT2TEX,">matoato");
	while(<TMP>){print TXT2TEX;}
	open(TMP,$H_RM." iran.tmp|");	close(TMP);
}

	########################################################
	#  LINUX:
	#	.cshrcと.bashrcにmatoatoのパス追加
	########################################################
sub	write_cshrc{
	my	($pwd);
	################## matoatoのパスを通す
	open(TMP,"pwd|");	while(<TMP>){	chop;	if(length($_)>0){$pwd=$_;}}	close(TMP);
	$MATOATORC_PATH = $pwd;

	open(TMP,'cp ~/.cshrc ~/.cshrc.org|');	close(TMP);
	open(TMP,'cp ~/.cshrc iran.tmp|');	close(TMP);
	# open(TMP,">>iran.tmp");	print TMP 'setenv PATH "${PATH}:'.$pwd.'"	# matoato用に追加しました'."\n";	close(TMP);
	open(TMP,">>iran.tmp");	print TMP 'set path = ($path '.$pwd.' )	# matoato用に追加しました'."\n";	close(TMP);
	open(TMP,"cp iran.tmp ~/.cshrc|");	close(TMP);
	open(TMP,"rm iran.tmp|");	close(TMP);
	open(TMP,"csh ~/.cshrc|");	close(TMP);
	print "\~\/\.cshrcを修正しました。元ファイルを\~\/\.cshrc\.orgにコピーしてます。\n";

	open(TMP,"cp ~/.bashrc ~/.bashrc.org|");	close(TMP);
	open(TMP,"cp ~/.bashrc iran.tmp|");	close(TMP);
	open(TMP,">>iran.tmp");	print TMP 'PATH=$PATH:'.$pwd.'	# matoato用に追加しました'."\n";	close(TMP);
	open(TMP,"cp iran.tmp ~/.bashrc|");	close(TMP);
	open(TMP,"rm iran.tmp|");	close(TMP);
	open(TMP,"bash ~/.bashrc|");	close(TMP);
	print "\~\/\.bashrcを修正しました。元ファイルを\~\/\.bashrc.orgにコピーしてます。\n";
}
	########################################################
	#  MS-Windows:
	# 	matoato のパスをautoexec.batに書く
	#	pl2bat matoatoをする
	########################################################
sub	write_autoexec{
	# my	($pwd);
	# ################## matoatoのパスを取得
	# open(TMP,"dir|");	while(<TMP>){	chop;	if(/\\/){$pwd=$_;last;}}	close(TMP);
	# $pwd=~s/^[ 	]*//;	$pwd=~s/[ 	]*のディレクトリ.*$//;
	# ################## matoatoのパスを通す
	# print '"スタート" - "設定" - "コントロールパネル" - "システムのプロパティ" を開き、"詳細"タグ - "環境変数"の変数のpathを"編集"し、次のパスを書き込んでください。'."\n\n	\;".$pwd."\n\n";
	open(TMP,">iran.bat");	&print_install_bat;	close(TMP);	# PATH追加 batファイル作成
	open(TMP,"iran.bat|");	close(TMP);						# PATH追加する

	open(TMP,"del iran.bat|");	close(TMP);					# batファイル削除

	open(TMP,"<iran.tmp");	while(<TMP>){print;}	close(TMP);	# Win95ではbatファイルのメッセージが
	open(TMP,"del iran.tmp|");	close(TMP);						# 表示されないので、その対処

}

sub	set_OS{ # OSの取得 200801
	$H_OS = $^O;
}

sub	print_install_bat{				# 	iran.batにインストールスクリプトを書く
	my	($tmp);
	$tmp=<<'-install_bat';
	@rem = '--*-Perl-*--
	@echo off
	if "%OS%" == "Windows_NT" goto WinNT
	perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
	goto end_perl
	:WinNT
	perl -x -S "%0" %*
	if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto end_perl
	if %errorlevel% == 9009 echo You do not have Perl in your PATH.
	goto end_perl
	@rem ';
	#!/usr/bin/perl
	#line 14

	use Cwd;
	use Config;
	use Win32::Registry;

	$cwd = getcwd();

	$ENVIRONMENT_KEY = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

	$matoato_dir = $cwd;	$matoato_dir =~ s/\//\\/g;
	$MATOATORC_PATH = $matoato_dir;
	$matoato_check = $matoato_dir;	$matoato_check =~ s/\\/\\\\/g;

	$path = $ENV{'PATH'};	# DOSのPATH
	unless ($path =~ /$matoato_check/i){	# PATHが通ってないとき
	#print "1 $tar\n2 $inst_dir\n3 $prefix\n4 $cwd\n5 $matoato_dir\n6 $matoato_check\n7 $path\n";	die;
		if(Win32::IsWinNT) {
			$Environment = 0;
			$type = 0;
			if($HKEY_LOCAL_MACHINE->Open($ENVIRONMENT_KEY, $Environment)) {
				if($Environment->QueryValueEx("PATH", $type, $path)) {
					unless ($path =~ /$matoato_check/){
						$path = $matoato_dir.';'.$path;
						$Environment->SetValueEx("PATH", -1, $type, $path);
						printf("PATHに $matoato_dir を追加しました。\n");
					}
				}
			}
		} else {
			$file = substr($ENV{'WINDIR'},0,2)."\\autoexec.bat";
			if(open(FILE, "<$file")) {
				@statements = <FILE>;
				close(FILE);
				$path_last_line = $line = 0;
				for $statement (@statements) {
					if($statement =~ /^\s*(SET\s+)?PATH\b/i){
						$path_last_line = $line ;
					}
					$line++;
				}
			}
			$path = "PATH=$matoato_dir;%PATH%\n";
			splice(@statements,$path_last_line+1,0,$path);
			if(open(FILE, ">$file")) {
				print FILE @statements;
				close(FILE);
				printf("autoexec.batのPATHに $matoato_dir を追加しました。\n");
				printf("PATHを有効にするにはコンピュータを起動し直してください。\n");
			}
			if(open(FILE, ">iran.tmp")) {
				print FILE "autoexec.batのPATHに $matoato_dir を追加しました。\n";
				print FILE "PATHを有効にするにはコンピュータを起動し直してください。\n";
				close(FILE);
			}
		}
	}

	__END__
	:end_perl
-install_bat
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	print TMP $tmp;
}

sub	pl2bat_matoato{				# 	matoato → matoato.batに変換
	open(TMP,">matoato.bat");
	$tmp = <<'-pl2bat_1of3';
	@rem = '--*-Perl-*--
	@echo off
	if "%OS%" == "Windows_NT" goto WinNT
	jperl -Leuc -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
	goto endofperl
	:WinNT
	jperl -Leuc -x -S "%0" %*
	if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
	if %errorlevel% == 9009 echo You do not have Perl in your PATH.
	goto endofperl
	@rem ';
-pl2bat_1of3
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	print TMP $tmp;
	open(TXT2TEX,"<matoato.pl");	while(<TXT2TEX>){	print TMP;}	close(TXT2TEX);
	$tmp = <<'-pl2bat_3of3';
	__END__
-pl2bat_3of3
	$tmp =~ s/^\t//;
	print TMP $tmp;
	print TMP ":endofperl";
	close(TMP);
}

	########################################################
	# インストールスクリプト end
	########################################################

####################################
#	txt2unix, txt2dos, txt2mac, h2z begin, 000813b
#	ただし改行コードは未...perl for win では \n=CRLFなので\r=CRとできるがLFを作れない
####################################
sub txt2unix{
	$H_OUT_JCODE = 'unix';
	&txt2jcode_print;	# コード変換 -> print
}
sub txt2dos{
	$H_OUT_JCODE = 'dos';
	&txt2jcode_print;	# コード変換 -> print
}
sub txt2mac{
	$H_OUT_JCODE = 'mac';
	&txt2jcode_print;	# コード変換 -> print
}
sub h2z{
	$H_OUT_JCODE = 'h2z';
	&txt2jcode_print;	# コード変換 -> print
}
sub	txt2jcode_print{
	my	($out,$jcode,$retcode);

	&check_eibun(0);	# 入力ファイルの日本語コード取得　→　$H_JCODEに代入

	if(    $H_OUT_JCODE eq 'unix' ){	$jcode='euc';		$retcode="\n";}
	elsif( $H_OUT_JCODE eq 'dos'  ){	$jcode='sjis';		$retcode="\r\n";}
	elsif( $H_OUT_JCODE eq 'mac'  ){	$jcode='sjis';		$retcode="\r";}
	if( $H_OS eq 'MS-Windows' && $H_OUT_JCODE eq 'dos' ){
		$retcode = "\n";	# 改行コードは未...perl for win では \n=CRLFなので\r=CRとできるがLFを作れない
	}
	open(IN ,"<".$H_INPUT_FILE);
	# if( $jcode=='sjis' ){
	# 	binmode IN, ":encoding(cp932)";
	# }else{
	# 	binmode IN, ":encoding(euc-jp)";
	# }
	open(OUT,">iran.tmp");
	# binmode OUT, ":encoding(cp932)";
	while(<IN>){
	  if( $H_OUT_JCODE ne 'h2z' ){
		chop;
		$out=$_;
		# no I18N::Japanese;	&jcode::convert(\$out,$jcode,$H_JCODE, "z");	use I18N::Japanese;# コード変換(use h2z)
		# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';}	&jcode::convert(\$out,$jcode,$H_JCODE);	if($H_PERL_VER==1){	eval 'I18N::Japanese;';}# コード変換(no h2z)
		$out = $out.$retcode;	# 改行コード変換
	  }else{
		$out=$_;
		# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';}	&jcode::convert(\$out,$H_JCODE,$H_JCODE, "z");	if($H_PERL_VER==1){	eval 'I18N::Japanese;';}# コード変換(use h2z)
	  }
		print OUT $out;
	}
	close(IN);
	close(OUT);
	open(TMP,$H_CP."   iran.tmp ".$H_INPUT_FILE."|");	close(TMP);
	open(TMP,$H_RM." iran.tmp|");	close(TMP);
}
####################################
#	txt2unix, txt2dos, txt2mac, h2z end
####################################

####################################
#	matoato --dvi, --html, --ps, --pdf対応,000813c,begin,000813k
####################################
#		matoato --pdf readme.txtなどの仕様：
#			   拡張子が省略されているとき、txtとみなす
#			→ txt より tex の日付が新しいとき tex をターゲットにする	if not → txt2tex
#			→ tex より dvi の日付が新しいとき dvi をターゲットにする	if not → jlatex
#			→ dvi より ps  の日付が新しいとき ps  をターゲットにする	if not → dvips
#			→ ps  より pdf の日付が新しいとき何もしない				if not → ps2pdf

sub read_matoatorc{
	my	($_org);
	# $H_GET_DVI='platex -interaction=nonstopmode $input';	#DVIに変換
	$H_GET_DVI='uplatex -interaction=nonstopmode -kanji=utf8 $input';	#DVIに変換 210801
	$H_GET_HTML='latex2html -split 1 $input';	#HTMLに変換
	$H_GET_PS='dvipsk $input';	#PSに変換
	#$H_GET_PDF='dvipdfm $input';	#PDFに変換
	$H_GET_PDF='dvipdfmx $input';	#PDFに変換 200624
	$H_GET_PDFA5='dvipdfm -p a5 $input';	#PDFに変換

	$_org=$_;
	open(MATOATORC,"<".$MATOATORC_PATH."\.matoatorc");
	# binmode MATOATORC,  ":encoding(cp932)";
	while(<MATOATORC>){
		chop;
		if( s/^[ 	]*ターゲットファイル：[ 	]*// ){	s/[ 	]*$//;	$H_TARGET_FILE = $_;}
		elsif( s/^[	 ]*OS：[ 	]*// ){					s/[ 	]*$//;	$H_OS = $_;}
		elsif( s/^[	 ]*エディタ：[ 	]*// ){				s/[ 	]*$//;	$H_EDITOR = $_;}
		elsif( s/^[	 ]*スペルチェック：[ 	]*// ){		s/[ 	]*$//;	$H_SPELL_CHECKER = $_;}
		elsif( s/^[	 ]*DVIに変換：[ 	]*// ){			s/[ 	]*$//;	$H_GET_DVI = $_;}
		elsif( s/^[	 ]*HTMLに変換：[ 	]*// ){			s/[ 	]*$//;	$H_GET_HTML = $_;}
		elsif( s/^[	 ]*PSに変換：[ 	]*// ){				s/[ 	]*$//;	$H_GET_PS = $_;}
		elsif( s/^[	 ]*PDFに変換：[ 	]*// ){			s/[ 	]*$//;	$H_GET_PDF = $_;}
		elsif( s/^[	 ]*DVIプレビュア：[ 	]*// ){		s/[ 	]*$//;	$H_PREVIEW_DVI = $_;}
		elsif( s/^[	 ]*HTMLプレビュア：[ 	]*// ){		s/[ 	]*$//;	$H_PREVIEW_HTML = $_;}
		elsif( s/^[	 ]*PSプレビュア：[ 	]*// ){			s/[ 	]*$//;	$H_PREVIEW_PS = $_;}
		elsif( s/^[	 ]*PDFプレビュア：[ 	]*// ){		s/[ 	]*$//;	$H_PREVIEW_PDF = $_;}
	}
	close(MATOATORC);
	$_=$_org;
	return $file;
}

#	&is_new_old($file1,$file2);	file1がfile2より新しいかfile2がないとき 1 を返す
# 修正日時：$mtime = (stat("../matoato"))[9];・・・1970 年 1 月 1 日 0 時 0 分 0 秒からの経過秒数

sub	is_new_old{
	my	($file1,$file2,$mtime1,$mtime2,$_org,$ret);
	$_org=$_;	$file1=$_[0];	$file2=$_[1];
	$mtime1 = (stat(encode($H_JCODE2,$file1)))[9];	if( length($mtime1)==0 ){	$mtime1=0;}
	$mtime2 = (stat(encode($H_JCODE2,$file2)))[9];	if( length($mtime2)==0 ){	$mtime2=0;}
	if( $mtime1 > $mtime2 ){	$ret = 1;}
	else{						$ret = 0;}
	$_=$_org;
	return $ret;
}

# --dvi: txt -> tex -> (dvi)
sub dvi{
	my	($cmd,$i,$tmp,$directory,$in);

	if( !($H_INPUT_FILE =~ /\.tex$/)  ){				# 拡張子がtex 以外のとき
		$H_OUTPUT_FILE = $H_INPUT_FILE;
		$H_OUTPUT_FILE=~s/\.(tao|txt|tex)$//;
		$H_OUTPUT_FILE=$H_OUTPUT_FILE."\.tex";
		if( &is_new_old($H_INPUT_FILE,$H_OUTPUT_FILE) ){#	txtがtexより新しいかtexがないとき
			&set_output_file('.tex');					#		texファイルのバックアップ
			&txt2tex;									#		texを作る

		}
		$H_INPUT_FILE = $H_OUTPUT_FILE;
	}

	$in = $H_INPUT_FILE;	$directory='';	if( $in=~s/.*[\\\/]// ){	$directory=$&;}

	# jlatex を３回実行
	$cmd = $H_GET_DVI;	$cmd=~s/\$input/$in/;
	$tmp=$in;	$tmp=~s/\.tex$/\.dvi/;	$cmd=~s/\$output/$tmp/;
	$H_INPUT_FILE = $directory.$tmp;	# &ps で必要

	if( $H_OS eq 'MSWin32' ){
		open(TMP,">iran.bat");	print TMP "cd ".$directory."\n".$cmd;	close(TMP);
		$cmd = "iran.bat";
	}elsif($H_OS eq 'darwin'){
		$cmd = "platex -interaction=nonstopmode " . $H_OUTPUT_FILE;
		open(TMP,$cmd." > test3.tmp |");	close(TMP);
		open(TMP,$cmd." > test3.tmp |");	close(TMP);
		open(TMP,$cmd." > test3.tmp |");	close(TMP);
	}else{
		$cmd = "cd ".$directory.";".$cmd;
	}

	if($H_OS ne 'darwin'){
		$i=1;
		# &print_("\"latex→dviコマンドをコール中 ($i/3) ...\"\n");	system($cmd);	$i++;
		# &print_("\"latex→dviコマンドをコール中 ($i/3) ...\"\n");	exec($cmd);	$i++;
		&print_("\"latex→dviコマンドをコール中 ($i/3) ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);	$i++;
		&print_("\"latex→dviコマンドをコール中 ($i/3) ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);	$i++;
		&print_("\"latex→dviコマンドをコール中 ($i/3) ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);	$i++;
		&print_("\n\"DVIファイルへの変換終了！\"\n");#print $cmd;
	}

	if( $H_OS eq 'MSWin32' ){	system("del iran.bat");}
}

# --html: txt -> tex -> (html)
sub html{
	my	($cmd,$i,$tmp,$directory,$in);

	if( !($H_INPUT_FILE =~ /\.tex$/)  ){				# 拡張子がtex 以外のとき
		$H_OUTPUT_FILE = $H_INPUT_FILE;
		$H_OUTPUT_FILE=~s/\.(tao|txt|tex)$//;
		$H_OUTPUT_FILE=$H_OUTPUT_FILE."\.tex";
		if( &is_new_old($H_INPUT_FILE,$H_OUTPUT_FILE) ){#	txtがtexより新しいかtexがないとき
			&set_output_file('.tex');					#		texファイルのバックアップ
			&txt2tex;									#		texを作る

		}
		$H_INPUT_FILE = $H_OUTPUT_FILE;
	}

	$in = $H_INPUT_FILE;	$directory='';	if( $in=~s/.*[\\\/]// ){	$directory="cd ".$&;}

	# latex2html を実行
	$cmd = $H_GET_HTML;	$cmd=~s/\$input/$in/;
	$tmp=$H_INPUT_FILE;	$tmp=~s/\.tex$/\.html/;	$cmd=~s/\$output/$tmp/;


	if( $H_OS eq 'MS-Windows' ){
		open(TMP,">iran.bat");	print TMP $directory."\n".$cmd;	close(TMP);
		$cmd = "iran.bat";
	}else{
		$cmd = $directory.";".$cmd;
	}

	&print_("\"latex→htmlコマンドをコール中 ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);
	# &print_("\"HTML file conversion completed!\"\n");#print $cmd;
	&print_("\"HTMLファイルへの変換終了！\"\n");#print $cmd;

	if( $H_OS eq 'MS-Windows' ){	system("del iran.bat");}
}

# --ps: txt -> tex -> dvi -> (ps)
sub ps{
	my	($cmd,$i,$tmp,$directory,$in);

	if( !($H_INPUT_FILE =~ /\.dvi$/)  ){	# 拡張子がdvi 以外のとき
		&dvi;								#	dvi作成
	}

	$in = $H_INPUT_FILE;	$directory='';	if( $in=~s/.*[\\\/]// ){	$directory=$&;}

	# dvi2ps を実行
	$cmd = $H_GET_PS;	$cmd=~s/\$input/$in/;
	$tmp=$in;	$tmp=~s/\.dvi$/\.ps/;	$cmd=~s/\$output/$tmp/;
	$H_INPUT_FILE = $tmp;	# &ps で必要

	if( $H_OS eq 'MS-Windows' ){
		open(TMP,">iran.bat");	print TMP "cd ".$directory."\n".$cmd;	close(TMP);
		$cmd = "iran.bat";
	}else{
		$cmd = "cd ".$directory.";".$cmd;
	}

	# open(TMP,"echo \"dvi→psコマンドをコール中 ...\";$cmd|");	while(<TMP>){	&print_($_);}close(TMP);
	&print_("\"dvi→psコマンドをコール中 ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);
	# &print_("\"PS file conversion completed!\"\n");#print $cmd;
	&print_("\"psファイルへの変換終了！\"\n");#print $cmd;

	if( $H_OS eq 'MS-Windows' ){	system("del iran.bat");}
}

# --pdf: txt -> tex -> dvi -> ps -> (pdf)
sub pdf{
	my	($cmd,$i,$tmp,$directory,$in);

	# if( !($H_INPUT_FILE =~ /\.ps$/)  ){	# 拡張子がps 以外のとき
	# 	&ps;								#	ps作成
	# }
	if( !($H_INPUT_FILE =~ /\.dvi$/)  ){	# 拡張子がdvi 以外のとき
		&dvi;								#	dvi作成
	}

	$in = $H_INPUT_FILE;	$directory='';	if( $in=~s/.*[\\\/]// ){	$directory=$&;}
	# $in=$H_INPUT_FILE;	$directory='';

	# dvipdfm を実行
	if($_[0] eq "a5"){	$cmd = $H_GET_PDFA5;}
	else{				$cmd = $H_GET_PDF;}
	$cmd=~s/\$input/$in/;
	$tmp=$in;	$tmp=~s/\.ps$/\.pdf/;	$cmd=~s/\$output/$tmp/;

	if( $H_OS eq 'MSWin32' ){
		open(TMP,">iran.bat");	print TMP "cd ".$directory."\n".$cmd;	close(TMP);
		$cmd = "iran.bat";
	}elsif($H_OS eq 'darwin'){
		$H_OUTPUT_FILE =~ s/\.tex/\.dvi/;
		$cmd = 'dvipdfmx ' . $H_OUTPUT_FILE;
		open(TMP,$cmd." > test3.tmp |");	close(TMP);
		system($H_RM,"test3.tmp");
	}else{
		$cmd = "cd ".encode('cp932',$directory).";".$cmd;
	}

	if($H_OS ne 'darwin'){
		&print_("\"dvi→pdfコマンドをコール中 ...\"\n");	open(TMP,$cmd."|");	while(<TMP>){	&print_($_);}close(TMP);
		# &print_("\"ps→pdfコマンドをコール中 ...\"\n");	system($cmd);
		&print_("\"PDFファイルへの変換終了！\"\n");#print $cmd;
	}

	if( $H_OS eq 'MSWin32' ){	system("del iran.bat");}
}

# --pdfpv: txt -> (pdf) 200624
# previewモードでpdf作成。引数はtxtのみ対応。latexmkrcが必要。コンパイルに成功した際logやauxを削除する<=これは不要かも？<=とりあえず削除
sub latexmk{
	my ($latexmode,$tmp);
	$latexmode = $_[0];
	&set_output_file('.tex');
	&txt2tex;
	$cmd = "latexmk " . $latexmode . " " . $H_OUTPUT_FILE;

	open(TMP,">","iran.bat");
	print TMP "cd \n" . $cmd;
	close(TMP);

	open(TMP,"iran.bat|");
	while(<TMP>){
		&print_($_);
		if(/pages, \d+ bytes/){
			$tmp = 1;
		}
	}
	close(TMP);

	if($tmp == 2){ # コンパイル出来た際auxやlogを消去...のはずがコンパイル失敗しても消去されてるので暫定なし 200624
		$cmd = "latexmk -c " . $H_OUTPUT_FILE;
		open(TMP,">","iran.bat");
		print TMP $cmd;
		close(TMP);

		open(TMP,"iran.bat|");
		close(TMP);
	}

	system("del iran.bat");

	if($tmp == 1){
		&print_("\"PDFファイルへの変換終了！\"\n");
	}
}

####################################
#	matoato --dvi, --html, --ps, --pdf対応,000813c,end
####################################
sub	print_help{
	my	$tmp;
	&print_('***** '.$VER.' ******'."\n");

	if( $H_OS eq 'Macintosh' ){
		$tmp = <<"-h";

	□見やすいテキストファイルを latex ファイルに変換(または逆変換)します．

	　使い方：
		　・テキストファイルを「まとあとv0.6」にドラッグ＆ドロップして下さい．

		　・ただし、テキストファイルの拡張子が tex のとき逆に txt ファイルを作ります．

		　・「まとあとv0.6」にドラッグ＆ドロップするとPDFファイルを作成します。
-h
	}else{
		$tmp=<<"-h";
		□見やすいテキストファイルを latex ファイルに変換(または逆変換)します．
		　使い方：
			　・テキストファイルを「まとあとv0.8」にドラッグ＆ドロップして下さい．
			　・ただし、テキストファイルの拡張子が tex のとき逆に txt ファイルを作ります．
			　・「まとあとv0.8（PDF）」にテキストファイルをドラッグ＆ドロップするとPDFファイルを作成します。
			　・「まとあとv0.8」, 「まとあとv0.8（PDF）」とmatoato081.plは同じフォルダに入れてください。

		□コマンドプロンプトの場合（c:\perl\binにmatoato081.plを入れてください）
		　使い方：perl matoato081.pl [-オプション] [ファイル]
			ファイルをtexファイルに変換。ただしファイルの拡張子が tex のとき，txtファイルに逆変換。
			例） perl matoato081.pl myfie.txt			---> myfile.tex を作成
				 perl matoato081.pl --pdf myfie.tex		---> myfile.pdf を作成
				 perl matoato081.pl myfie.tex			---> myfile.txt を作成
			スイッチ：（未対応を含みます。）
			・matoato -h, -?		：	matoatoの使い方を簡単に示します．
			・matoato --txt2tex		：	拡張子にかかわらず txt2tex します．
			・matoato --tex2txt		：	拡張子にかかわらず tex2txt します．
			・matoato -j			：	ファイルを和文とみなして tex2txt します．
			・matoato -e			：	ファイルを英文とみなして tex2txt します．
			・matoato --help		：	matoatoの使い方を詳細に示します．
			・matoato --fig_ex1.eps	：	マニュアルに挿入するTgifファイルを出力します。
										matoato --help > readme.txt
										matoato readme.txt
										matoato --fig_ex1.eps > fig_ex1.eps
										として platex するとマニュアルを作成できます。
			・matoato --CELsty		：	卒論や修論の公聴会用要旨のstyファイルを出力します。
			・matoato --ANNUALsty	：	年次大会用要旨のstyファイルを出力します。
			・matoato --txt2mac		：	Mac の日本語コード(SJIS, 改行コードはCR)に変換
			・matoato --txt2dos		：	DOS の日本語コード(SJIS, 改行コードはCRLF)に変換
			・matoato --txt2unix	：	unixの日本語コード(EUC, 改行コードはLF)に変換
			・matoato --h2z			：	半角カナを全角カナに変換
			・matoato --dvi			：	dviファイルに変換
			・matoato --html		：	htmlファイルに変換
			・matoato --ps			：	psファイルに変換
			・matoato --pdf			：	pdfファイルに変換(A4)
			・matoato --pdfa5		：	pdfファイルに変換(A5)
			・matoato --pdfpv		：	pdfファイルに変換(latexmk,txtのみ)
-h
	}
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	&print_($tmp);
}

sub set_output_file{    # 出力ファイルの設定
	my	($_org, $filename, $kakutyousi, $f, $n, $f1, $_tmp, $aft, $fname, $fname0,$nBACK,$nBACK1,$fBACK);

	$_org = $_;	$kakutyousi = $_[0]; # $_orgには空の文字列のはず。いる？==>初期化のためにいりそう 
	$_ = $H_INPUT_FILE; # $H_INPUT_FILEはperlの入力第一引数、すなわちファイル名

	$H_INPUT_FILE_DIRECTORY = '';	#000606c
	if( s/.*[\/\\]// ){           # ../a.txt or ..\a.txt → a.txt, Macは : ???...未対 
		$H_INPUT_FILE_DIRECTORY = $&;	#000519a "$&"はマッチした部分、この場合任意の文字と/or\
		$fname = $_; # 残りの部分
		$_ = $H_INPUT_FILE_DIRECTORY;
		if($H_OS eq 'MSWin32'){
			while(s/(.*?)[\\\/](.*?)([\\\/])(.*)/$3$4/){$filedir_name = $2;}
			$_ = getcwd;
			s/(.*)[\\\/](.*)/$2/;
			if($filedir_name eq $_){
				$filedir_name = '';
			}
		}
		$_ = $fname;
		# $_=$&.$_;	#000813p $_を元に戻す 210701 削除
		$C_filedir = 1;
		$H_INPUT_FILE = $fname; # a.txt
		$_ = $H_INPUT_FILE;
		s/\.(tex|txt|tao)//;	#000813i .tex or .txt or .taoの拡張子を削除
		$filename = $_;
		$fname = $filename;
		$fname0 = $filename;
		$H_OUTPUT_FILE = $filename . $kakutyousi;
	}else{ # 210701 サブディレクトリのために作り直し
		$C_filedir = 0;
		s/\.(tex|txt|tao)//;	#000813i .tex or .txt or .taoの拡張子を削除
		$fname0=$_;
		$filename = $_;
		$fname=$filename;
		$H_OUTPUT_FILE = $filename.$kakutyousi; # ファイル名を任意の拡張子にする
	}
	$nBACK = "backup";
	$nBACK1 = $filename . "_" . $nBACK; # backupのフォルダ名 200701
	# 	s/(\..*)//;	#$kakutyousi/;
	# 	$fname =~ s/\.(tex|txt|tao)//;	$fname0=$fname;	$fname=$fname.$kakutyousi;
	# print $fname0."101\n";
	# print $fname."102\n";
	# s/\.(tex|txt|tao)//;	#000813i .tex or .txt or .taoの拡張子を削除
	# $fname0=$_;
	# $fname=$fname.$kakutyousi;
	# $filename = $_;
	# $fname=$filename;
	# $H_OUTPUT_FILE = $filename.$kakutyousi; # ファイル名を任意の拡張子にする
	# $nBACK = "backup";
	# $nBACK1 = $filename . "_" . $nBACK; # backupのフォルダ名 200701
	# print $H_INPUT_FILE_DIRECTORY." dire\n";
	# print $H_OUTPUT_FILE."\n";
	# print $filename." filename\n";
	# print $fname." fname\n";

	$f = 1;	$n = 1;	$f1=0;	$fBACK=0;	$fPIC=0;	$cfile=0;#	$_tmp = $H_OUTPUT_FILE;
	while($f){
		$f = 1;
		if($H_OS eq 'MSWin32' and $C_filedir == 0){
			open(LS,$H_LS." ".encode($H_JCODE2,$H_INPUT_FILE_DIRECTORY).'|');		#000508a,020322c open(LS,"dir |")
		}elsif($H_OS eq 'MSWin32' and $C_filedir == 1){
			if($cfile==0){
				if($filedir_name ne ''){
					chdir encode($H_JCODE2,$filedir_name) or die $!;
				}
				$cfile = 1;
			}
			open(LS,$H_LS." ".encode($H_JCODE2,'').'|');		#000508a,020322c open(LS,"dir |")
		}elsif($H_OS eq 'darwin'){
			open(LS,$H_LS." ".$H_INPUT_FILE_DIRECTORY.'|');		#000508a,020322c open(LS,"dir |")
		}
		while(<LS>){
			chomp;
			if($H_OS eq "MSWin32"){
				$_ = decode($H_JCODE2,$_);
				if(/[ 	]+<DIR>[ 	]+$nBACK1+$/){	# 「バックアップフォルダ」を見つけたフラグ
					$fBACK = 1;
				}
				if(/[ 	]+<DIR>[ 	]+picture+$/ && $C_filedir != 1){	# 「picture」を見つけたフラグ
					$fPIC = 1;
				}
			}elsif($H_OS eq "darwin"){
				if(/[ 	]$nBACK1\//){					# 「バックアップフォルダ」を見つけたフラグ
					$fBACK = 1;
				}
				if(/[ 	]picture\// && $C_filedir != 1){					# 「picture」を見つけたフラグ
					$fPIC = 1;
				}
			}
	# print "--".$_."---\n";
	# print $H_OUTPUT_FILE."\n";
	# if( $H_OS eq 'MS-Windows' ){	#000723b,020322c
	# 			$aft='';
	# 			while(s/^([^ 	]+)[ 	]*// ){	# for DOS
	# 				$aft = $_;	$_=$1;
	# 				if( $_ eq $H_OUTPUT_FILE ){		$H_OUTPUT_FILE = $filename.'_'.$n.$kakutyousi;	$f = 2;	$f1=1;	last;}
	# 				$_=$aft;
	# 			}
	# }else{
	# 			if( $_ eq $H_OUTPUT_FILE ){
			if( (/$filename.*$kakutyousi/)&&(/^$fname$/||/^$fname[ 	]/||/[ 	]$fname$/||/[ 	]$fname\./||/[ 	]$fname\*$/) ){#020322c  filenameとfnameは別物！！！
	# print $fname." ".$kakutyousi."  oooo\n";
				$fname = $fname0.'_'.$n.$kakutyousi;
				$f = 2;
				$f1=1;
				last; # while(<LS>)のlast
			}
	#}
		}
		if( $f==1 ){
			last; # while(<$f>)のlast
		}elsif( $f==2 ){
			$n++;
		}
		close(LS);#020322c
	}

	if($cfile == 1){
		chdir ".." or die $!;
	}

	if($H_BACK == 1){
		if($fBACK == 0){
			if($H_OS eq "MSWin32" and $C_filedir == 0){
				system("md ".encode("cp932",$nBACK1));
			}elsif($H_OS eq "MSWin32" and $C_filedir == 1){
				chdir encode($H_JCODE2,$H_INPUT_FILE_DIRECTORY) or die $!;
				system("md ".encode("cp932",$nBACK1));
				chdir '..' or die $!;
			}elsif($H_OS eq "darwin" and $C_filedir == 0){
				system("mkdir ".$nBACK1);
			}elsif($H_OS eq "darwin" and $C_filedir == 1){
				system("mkdir ".$H_INPUT_FILE_DIRECTORY.$nBACK1);
			}
		}

		if($C_filedir == 1){
			if($C_filedir == 1){
				if($H_OS eq "MSWin32"){
					open(LS,$H_LS." |");
				}elsif($H_OS eq "darwin"){
					open(LS,$H_LS." |");
				}
				while(<LS>){
					chomp;
					if($H_OS eq "MSWin32"){
						$_ = decode($H_JCODE2,$_);
						if(/[ 	]+<DIR>[ 	]+picture+$/){	# 「picture」を見つけたフラグ
							$fPIC = 1;
						}
					}elsif($H_OS eq "darwin"){
						if(/[ 	]picture\//){					# 「picture」を見つけたフラグ
							$fPIC = 1;
						}
					}
				}
			}
		}

		if($H_PICTURE == 1 and $H_PICTURE_1 == 1){
			if($fPIC == 0){
				if($H_OS eq "MSWin32"){
					system("md ".encode("cp932","picture"));
				}elsif($H_OS eq "darwin"){
					system("mkdir "."picture");
				}
			}
			
			if($H_OS eq 'MSWin32'){
				# system($H_MV." ".encode('cp932','*.JPG')." ".encode('cp932','*.jpg'));
				# system($H_MV." ".encode('cp932','*.JPEG')." ".encode('cp932','*.jpeg'));
				system($H_MV." ".encode('cp932',"*\.jpg")." ".encode('cp932',"\.\\picture\\"));
				system($H_MV." ".encode('cp932',"*\.png")." ".encode('cp932',"\.\\picture\\"));
				system($H_MV." ".encode('cp932',"*\.eps")." ".encode('cp932',"\.\\picture\\"));
			}elsif($H_OS eq 'darwin'){
				system($H_MV." *\.\{jpg\,jpeg\} picture\/\.");
				system($H_MV." *\.\{png\,PNG\} picture\/\.");
				system($H_MV." *\.eps picture\/\.");
			}
		}

		if(($H_OS eq "MSWin32") and ($C_filedir == 0)){
			chdir encode($H_JCODE2,$nBACK1) or die $!;
		}elsif(($H_OS eq "MSWin32") and ($C_filedir == 1)){
			chdir encode($H_JCODE2,$H_INPUT_FILE_DIRECTORY.$nBACK1) or die $!;
		}elsif(($H_OS eq "darwin") and ($C_filedir == 0)){
			chdir $nBACK1 or die $!;
		}elsif(($H_OS eq "darwin") and ($C_filedir == 1)){
			chdir $H_INPUT_FILE_DIRECTORY.$nBACK1 or die $!;
		}
		$f = 1;
		while($f){
			$f = 1;
			if($H_OS eq "MSWin32"){
				open(LS,$H_LS." |");
			}elsif($H_OS eq "darwin"){
				open(LS,$H_LS." |");
			}
			while(<LS>){
				chop;
				if($H_OS eq "MSWin32"){
					$_ = decode($H_JCODE2,$_);
				}
				if( (/$filename.*$kakutyousi/)&&(/^$fname$/||/^$fname[ 	]/||/[ 	]$fname$/||/[ 	]$fname\./||/[ 	]$fname\*$/) ){#020322c  filenameとfnameは別物！！！
					$fname = $fname0.'_'.$n.$kakutyousi;
					$f = 2;
					$f1=1;
					last; # while(<LS>)のlast
				}
			}
			if( $f==1 ){
				last; # while(<$f>)のlast
			}elsif( $f==2 ){
				$n++;
			}
			close(LS);
		}
		chdir ".." or die $!;
	}


	# $_tmp = $H_INPUT_FILE_DIRECTORY.$fname;
	$_tmp = $fname;
	if($f1==1){
	# 000813j		&print_('% matoato Warning: '.$_tmp.' はすでにあるので、'.$H_OUTPUT_FILE." に出力します。\n");
	# 		if( $H_OS eq 'MS-Windows' ){
	# 			open(TMP,">iran.bat");	print TMP "copy \"".$_tmp."\" \"".$H_OUTPUT_FILE."\"\n del \"".$_tmp."\"";	close(TMP);	$cmd = "iran.bat";
	# 			open(TMP,$cmd."|");	system("del iran.bat");	close(TMP);
	# 		}else{
		# open(TMP,$H_CP." \"".encode('cp932',$H_OUTPUT_FILE)."\" \"".encode('cp932',$_tmp)."\"|");	close(TMP);
		if($H_BACK == 1){
			if($H_OS eq "MSWin32"){
				open(TMP,$H_CP." ".encode($H_JCODE2,$H_OUTPUT_FILE)." ".encode($H_JCODE2,$_tmp)."|");	close(TMP);
				open(TMP,$H_MV." ".encode($H_JCODE2,$_tmp)." \"\%CD\%\\".encode($H_JCODE2,$nBACK1)."\"|"); close(TMP);
				open(TMP,$H_RM." ".encode($H_JCODE2,$H_OUTPUT_FILE)."|");	close(TMP);
			}elsif($H_OS eq "darwin"){
				open(TMP,$H_CP." ".$H_OUTPUT_FILE." ".$_tmp."|");	close(TMP);
				open(TMP,$H_MV." ".$_tmp." ".$nBACK1."/|");	close(TMP);
				open(TMP,$H_RM." ".$H_OUTPUT_FILE."|");	close(TMP);
				$H_OUTPUT_FILE = decode($H_JCODE2,$H_OUTPUT_FILE);
				$_tmp = decode($H_JCODE2,$_tmp);
			}
		}else{
			open(TMP,$H_CP." \"".encode($H_JCODE2,$H_OUTPUT_FILE)."\" \"".encode($H_JCODE2,$_tmp)."\"|");	close(TMP);
			open(TMP,$H_RM." \"".encode($H_JCODE2,$H_OUTPUT_FILE)."\"|");	close(TMP);
		}
		&print_('% matoato Warning: ' . $H_OUTPUT_FILE . ' はすでにあるので、これを' . $_tmp . " にバックアップしました。\n");
	}
	$_ = $_org; # $_="" $_をリセットする
}

# matoatoの使い方の詳細(readme.txt)
sub	print_readme{
	my($tmp);
	$tmp= <<'USAGE_DISCREPTION';
	\documentclass[uplatex,10ptj,a4j]{jsarticle}
	"\usepackage{ascmac}\textheight240mm\topmargin-70pt"
	"\makeatletter"
	"\renewcommand*{\l@section}[2]{"
	"\ifnum \c@tocdepth >\z@"
	"\addpenalty{\@secpenalty}"
	"\addvspace{1.0em \@plus\jsc@mpt}"
	"\begingroup"
	"\parindent\z@"
	"\rightskip\@tocrmarg"
	"\parfillskip-\rightskip"
	"\leavevmode\headfont"
	"\setlength\@lnumwidth{\jsc@tocl@width}\advance\@lnumwidth 0em"
	"\advance\leftskip\@lnumwidth \hskip-\leftskip"
	"#1\nobreak\hfil\nobreak\hbox to\@pnumwidth{\hss#2}\par"
	"\endgroup"
	"\fi}"
	"\def\l@subsection#1#2{\@dottedtocline{2}{1.5em}{2.3em}{#1}{#2}}"
	"\def\l@subsubsection#1#2{\@dottedtocline{3}{3.8em}{3.2em}{#1}{#2}}"
	"\makeatother"
	題名：まとあとのマニュアル

	作成：まとあと

	日付：\today

	要約：
	　"matoato"は、"WYSIWYG"っぽくて見やすいテキストファイル"(拡張子txt)"を LaTeX ファイル"(拡張子tex)"に変換します。
	また、逆変換("\LaTeX" → 見やすいテキストファイル)もできます。
	セールスポイントは、教科書のように綺麗な LaTeX 文書を、簡単に作成・修正できることです。
	とくに数式や表が多いレポートや論文など、定型文書の作成に向いています。
	　このソフトについてわからないことがありましたら、この文書をエディタで開き、知りたいキーワードを”検索／"Find"”してください。
	きっとヒントが見つかると思います。
	問い合わせ，コメントなどは"(matoato0@gmail.com)"まで。

	1章：見やすいテキストファイル"(txtファイル)"の一例


	　"matoato"のセールスポイント"SP"1)～"SP"2)を箇条書にします。
		　"SP"1) 行列を含む式，表，箇条書，図を綺麗に簡単に書ける！
		　"SP"2) 式番号，参考文献番号などを記号(ラベル)として扱えるので、式の追加などが楽々！
	　表の例を、下に示します。
		表：
		------------------------------------------------------------
		| ノルム || ｜x^2｜, ∥x1∥, ∥xab∥1, ∥α1∥2, ∥φa∥∞ |
		============================================================
		|   式   || a = lim_{t→∞} ∫ β1(t)/Φa(t) dt            |
		------------------------------------------------------------

	　式の例を、（eqn:1）, （eqn:2）式に示します。

		x = ／ Kp \ X2 (0) , ， k=N+1					（eqn:1）
			＼ ∞          , ， k ≧ N+2
		a =／x ＼ + (a- ／a1 , 0   , … , 0  ＼ + ／x, 1＼ ^ {-1} ) - a	（eqn:2）
		＼y ／       | a2 , a1  , ・., 0   |   | 2, 3 |
						| ： , ：  , ・., 0   |   ＼z, 9／
						＼an , am  , … , a1 ／

	　図の例を、図（fig_ex1）に示します。
		図："matoato"の広がり（fig_ex1.eps,0.6倍）	% ←図を挿入するコマンドです。


	\clearpage	% ← 改ページのLaTeXコマンドです。
	"\setcounter{tocdepth}{3}"
	目次：
	\clearpage	% ← 改ページのLaTeXコマンドです。

	2章："matoato"のセールスポイント

	1節："matoato"によるLaTeXの弱点の克服

	　論文やレポートなどの定型文書を作成するとき、LaTeX（参：TeX-Faq）のメリットは次の3点と考えます。
		　1) 非常に美しく綺麗。(教科書などの成書なみ)
		　2) 式，図，表，参考文献，箇条書，章などの番号を記号(ラベル)で扱える。(これができるワープロは少ない)
		　3) 無料。
	とくに2)は、式番号が非常に多い文書を書くとき、途中で式を追加しても、式番号を気にしなくてもいいので重宝します。

	　逆にデメリットは、次の点です。
		　・難しい。(冗長と思われるコマンドが多い)
	LaTeXの作者（参：Knuth）は組版印刷のエキスパートであり、いかに美しく数式などを表現するかを第一に考えたためと思われます。
	文書の書きやすさを考えて作ったとは思われません。
	組版印刷に興味のない私たちにとって、書く内容は考えるべきですが、書くための手段に時間をかけたくありません。

	　"matoato"は、上記欠点を克服するもので、次の特徴があります。
		　1) 直感的にわかりやすい記述をすれば、これをLaTeXに変換できる。(とくに式，図，表，箇条書，参考文献にいえます)
		　2) LaTeXのコマンドを、””で囲むことにより、そのままTeXファイルに記述できるので、高度なLaTeXの表現を直接活用できる。
	特徴1)は、”直感的にわかりやすく人間に理解できる記述でも、機械に理解できるはずだ”という考えに基づいています。
	LaTeXと"matoato"の関係は、アセンブラと"C"言語に似ていると思います。
	特徴2)によって、よりエキスパートな表現を"txt"ファイルで行うことができます。

	　この文書"マニュアル.txt"と、これを"matoato"して得られる"マニュアル.tex"、さらにそれを"PDF"にした"マニュアル.pdf"を比較してみてください。
	いかに"txt"ファイル"(マニュアル.txt)"が見やすく、TeXファイルが暗号のように難解なものかわかると思います。
	さらに驚くべきことは、"matoato"は逆変換もできること、すなわちTeXファイルから"txt"ファイルを作成できることです。
	つまり、見やすい"txt"ファイルと難解なTeXファイルは相互に変換可能であり、両者に含まれる情報は、等価ということです。
	　ただし、バグも多くありますので、目でチェックお願いします。
	変換後の"tex"ファイルには、バグレポートとして次のような"Warning"メッセージをコメントとして記述していますので、文章中の"Warning"を検索してご参考ください。
	% ↓ そのままの文章を枠で囲んで印刷するときのLaTeXコマンドです。
	\begin{shadebox}\begin{verbatim}
	% txt2tex Warning(25): カッコが")("のように開いています。
	% txt2tex Warning(274): 左カッコが多いかも？( or [ =2, ) or ] =0
	\end{verbatim}\end{shadebox}
	「"Waring(行番号):その内容"」の形式です。
	期待した結果が得られないときは、”"\verb|\frac{a}{b}|"”のようにLaTeXコマンドを”で囲って直接記述してください。

	　ここでもう一度いいます。
	"matoato"は、LaTeXの暗号のような書きにくさを克服し、論文等を簡単に書くために作ったものです。

	　"matoato"のように、LaTeXの表現力を損なわずに、書きやすくする努力が今までなされていなかった理由は、次の2点にあると考えます。
		　・主なユーザが大学などの研究者であり、ユーザフレンドリーさよりも、使いこなすことに喜びを感じ、それで満足していた。
		　・主に欧米で使われていて、βやΣなどの記号をテキストで簡単に表現できない。(もちろん日本語では全角文字(2バイト文字)で表現できます)

	　"matoato"を使って欲しい人は、次に当てはまる人です。
		　・論文やレポートなどLaTeXのスタイルファイルが用意されている定型文書を、非常に簡単に、かつ非常に美しく書きたい。
		　・卒論などの作成のために、どうしてもLaTeXを使わなければならない。
	LaTeXの初心者からエキスパートまで満足していただけると思います。


	2節：従来の文書作成ツールとの比較

	　論文のように、数式が多用され、LaTeXスタイルファイルによってレイアウトやフォント設定が定まった定型文書を書く場合の、各種ツールの比較表を表（表：比較表）に示します。
		表：比較表
		-----------------------------------------------------
		|         |美しさ|連番|作成しやすさ||	総  評		|
		=====================================================
		|"MS Word"|  ×  | △ |    △      ||美しくない		|
		| LaTeX   |  ○  | ○ |    ×      ||難しい			|
		| "Lyx"   |  ○  | ○ |    △      ||やや難しい		|
		|まとあと |  ○  | ○ |    ○      ||美しくて簡単	|
		-----------------------------------------------------
	美しさは、定型文書のとおりのレイアウトやフォントサイズや飾りをどれだけ忠実に再現できるかを意味します。
	連番は、式番号などをラベルで書いておき、印刷の際は順序正しい数字で表現できる機能を指します。
	作成しやすさは、文書作成の容易さを意味します。
	ワープロは、醜く重く、連番を使えないものがほとんどで、操作を覚えるのも大変です。
	"plain2"は、数式と式の連番に対応しておらず、数式の作成が困難です。
	LaTeXは、美しく、連番も"OK"ですが、文書作成が困難です。
	"Lyx"は、美しく、連番も"OK"ですが、操作を覚える必要があります。
	さらにαなどを書くために、わざわざパレットを開いて選択しなければなりません。
	"GUI"でわかりやすいのですが、日本語"IME"で単に”あるふぁ”→αと変換する方が手軽だと思います。
	"matoato"は、数式を多用する定型文書作成に最も適しています。



	3章："txt"ファイルの書き方・文法

	0節：LaTeXスタイルファイルの設定

	LaTeXスタイルファイル（参：bear-bear-collection）の設定は、例えば以下の記述を文頭に書いて行います。
	% ↓ そのままの文章を枠で囲むときのLaTeXコマンドです。
	\begin{screen}\begin{verbatim}
		\documentclass[a4j]{jsarticle}
		\usepackage[dvipdfmx]{graphicx}
	\end{verbatim}\end{screen}
	この場合は、LaTeXスタイルファイルとして",a4j.sty"と"jsarticle.cls"を用いた例です。
	この記述は省略可能で、省略時にはこれら3つのスタイルファイルが、デフォルトで設定されます。
	　以下、"txt"ファイルに記述する内容を角丸四角で囲み、それが"pdf"ファイルに表示される部分を影付四角で囲みます。

	1節：題名など1ページ目のタイトルページ
	タイトルページは、文頭から”章：”の間に以下のように書きます。
	% ↓ そのままの文章を枠で囲んで印刷するときのLaTeXコマンドです。
	\begin{screen}\begin{verbatim}
	題名：源氏物語

	作成：紫式部
	要約：
	平安時代のイケメンで皇族の光源氏が、多くの女性と恋愛を繰り返す恋愛小説。世界最古の長篇小説である。
	日付：2011年12月06日

	目次：
	表目次：
	図目次：
	\end{verbatim}\end{screen}
	これらは、どれを省略しても構いません。
	1つのコマンドを1行に書いてください。
	”目次：”，”表目次：”，”図目次：”の3つは，それぞれ章，表，図の目次を作るコマンドで、文書のどこに書いても有効です。

	2節：本文

	2.1節節：章，節，付録，定理，補題，証明
	章，節，付録，定理，補題，証明などは、行頭に次のように書きます。
	\begin{screen}\begin{verbatim}
	1章：光源氏の初恋（1章のラベル）
	2節：光源氏の初恋の日

	2.1節節：光源氏の初恋の日の朝

	2.1-1節節節：光源氏の初恋の日の朝ごはん

	章：光源氏の初失恋
	節：光源氏の初失恋の日の夜
	節節：光源氏の初失恋の日の晩ごはん
	節節節：光源氏の初失恋の日の晩ごはんのあとで

	付録：定理など

	補題：1
	我輩は肉が好き．
	補題終：
	補題：2
	猫も肉が好き．
	補題終：
	定理：1
	我輩は猫である．
	定理終：
	証明：1
	補題（補題：1），（補題：2）より，肉が好きな我輩は猫である．
	ゆえに定理（定理：1）が導かれる．
	証明終：
	\end{verbatim}\end{screen}

	章題などは、行頭の「章：」のあとに、1行にまとめて書いてください。
	「章：」や「節：」などの前に書かれた、章番号など数字(0～9)と記号(.-)は、書いても書かなくても正しい番号が作成・印刷されます。
	(”2-1章：”は”章：”と等価です)
	参照ラベルは、”"章：はじめに（ラベル）"”のとき、"（ラベル）章"と書くと1章となります。
	”1章：はじめに”のとき、（章：はじめに）章と書くと1章となります。


	上記の例の証明などの部分は、"pdf"に変換すると以下のようになります。
	\begin{shadebox}
	補題：1
	我輩は肉が好き．
	補題終：
	補題：2
	猫も肉が好き．
	補題終：
	定理：1
	我輩は猫である．
	定理終：
	証明：1
	補題（補題：1），（補題：2）より，肉が好きな我輩は猫である．
	ゆえに定理（定理：1）が導かれる．
	証明終：
	\end{shadebox}


	2-2節節：段落


	段落の字下げは、行頭に全角スペース1つ”　”または半角スペース2つ”  ”を書いて行います。
	改行のみの行(空行)は無視されます。
	空行を入れたいときは\verb!\vspace{1zw}!と記述してください。
	行頭にタブを書いたとき、後述の図，表，式，箇条書のいずれかの処理が行われます。

	2.3節節：アルファベットや記号と半角ダブルクォーテーション


	式以外のアルファベットや記号や数字などは、数式とみなされ、（3節：式）で述べる”下付き”と”分数”処理が行われます。
	これらの処理を行わないためには、文字を半角ダブルクォーテーションで、\verb!"apple"!のように囲んでください。(複数行にわたって囲まないでください)
	半角ダブルクォーテーションを文書に書くときは、全角ダブルクォーテーションを書いてください。
	全角ダブルクォーテーションを文書に書くときは、\verb!"”"!と書いてください。
	あるいは、"\#define	英文："で下付き・分数処理を無効に設定することもできます。(とくに英語文書作成時に有効)
	全角アルファベット("ａ"～"ｚ", "Ａ"～"Ｚ")と全角数字("０"～"９")は、自動的に半角に変換されます。
	全角のままにしたい場合は、文字を半角ダブルクォーテーションで、\verb!"ｘｙｚ"!のように囲んでください。

	3節：式
	行頭に”タブ”を書くと、式の行として処理します。例えば、
	\begin{screen}\begin{verbatim}
		y1(t) = ∫α(t) "dt" + lim_{t→∞} β^t/{γ(t)}		（1）
	\end{verbatim}\end{screen}
	と書くと、"pdf"では
	　\begin{shadebox}
		y1(t) = ∫α(t) "dt" + lim_{t→∞} β^t/{γ(t)}		（1）
	\end{shadebox}
	のように表示されます。
	ただし、行頭の”タブ”に”表：”，”図：”,”縦：”,”横：”が続くと、後述の表と図の処理になります。

	節節：下付き
	"an1"がan1のようになります。
	この処理を無効にするためには、\verb!"an1"!のように半角ダブルクォーテーションで囲んでください。
	行頭の”タブ”に続く式以外の文章でこの処理を無効にするには、あらかじめ行頭に
		"\#define	英文："
	と記述してください。この行以降で、下付き・分数処理を無効に設定することができます。(とくに英語文書作成時に有効)

	節節：分数

	"txt"ファイルに
	\begin{screen}\begin{verbatim}
	a/b, a(t)/b, a/b(t), (1+a)/b(t), (a+b)/b, a/(b+c), a(t)/(b+1), a/＾￣~b
	β1(t)/Φa(t), (a+b)(c+d)/(e+f)(g+h), ((a+b)(c+d))/((e+f)(g+h)), a/b/c/d/e
	a^~b/c_＾d, a^~b/c_＾(a(t)+b(t))
	＾~￣α^{β+ab}_{γ-δ}
	￣yp (s) = Kp \ { {( Bp (s))/( Ap (s))} } \ ￣up (s)
	\end{verbatim}\end{screen}

	のように書くと、
	\begin{shadebox}
	a/b, a(t)/b, a/b(t), (1+a)/b(t), (a+b)/b, a/(b+c), a(t)/(b+1), a/＾￣~b
	β1(t)/Φa(t), (a+b)(c+d)/(e+f)(g+h), ((a+b)(c+d))/((e+f)(g+h)), a/b/c/d/e
	a^~b/c_＾d, a^~b/c_＾(a(t)+b(t))
	＾~￣α^{β+ab}_{γ-δ}
	￣yp (s) = Kp \ { {( Bp (s))/( Ap (s))} } \ ￣up (s)
	\end{shadebox}
	のようになります。
	この処理を無効にするためには、\verb!a"/"b!のようにスラッシュ"/"を半角ダブルクォーテーションで囲んでください。
	行頭の”タブ”に続く式以外では、あらかじめ行頭に
		"\#define	英文："
	と記述しておくことにより、以降の行での下付き・分数処理を無効に設定することもできます。(とくに英語文書作成時に有効)
	　割り算記号として全角文字”／”を使わないで下さい。
	これは行列のカッコとみなされてしまいます。


	節節：行列，ノルム，積分，極限など
	行頭に”タブ”、続いて式、続いて（）で囲まれた参照ラベルを書きます。
	式の後ろに"（）"を書くと、式番号が書かれますが、式の参照ラベルは作られません。
	式の後ろに何も書かない、または（欠番：）と書くと、式番号も参照ラベルも作られません。
	行列の場合は、"\fbox{（ラベル,[中左右）}"と、ラベルに加えて行列のカッコ(”(”か”｛”か”[”)と、列の文字寄せを指定できます。
	省略時、行列のカッコは”[”、文字は左寄せはです。
	省略時、左カッコのみの行列のカッコは”｛”、文字は左寄せはです。
	ラベルだけを省略し、式番号を付ける場合は”（,[中左右）”と、カンマ”,”を付けてください。
	式番号を付けない場合は”（欠番：,[中左右）”と、”欠番：”というラベルを付けてください。
	もしも”（[中左右）”と書くと、ラベル名が”[中左右”であるとみなされます。
	”中左右”は、右端の文字(例では右)が連続するものとみなされます(”中左右右右右右右”と等価)。
	"txt"ファイルに以下のように書くと、（eqn:5）～（eqn:7）式のようになります。
	式番号の参照ラベルは"（eqn:5）～（eqn:7）式"と書きます。
	\begin{screen}\begin{verbatim}
		a ∈ lim_{t→∞} ∫ β1(t)/Φa(t) dt	（eqn:5）
		
		絶対値  :｜x｜, ノルム  :∥x∥, 1ノルム :∥x∥1, 2ノルム :∥x∥2, ∞ノルム:∥x∥∞

		
	%		 ↓ 行列の1行目は揃えてください。
		／x ＼        ／a1 , 0   , … , 0  ＼   ／x, 1＼
		a =| y  | + (λ- | a2 , a1  , ・., 0   | + | 2, 3 | ^{-1} ) - a （eqn:6）
		＼z ／        | ： , ：  , ・., 0   |   ＼z, 9／
						＼an , am  , … , a1 ／
		
			／0           , ∵ k ≦ N
		x = | Kp \ X2 (0) , ， k=N+1
			＼∞          , ， k ≧ N+2
		
		／Pv ＼  ∝ ／MP^b , 1/2     ＼  ／∥￣~a∥∞＼ / 3π	（,(中）
		＼Xv2／     ＼MP2  , √{＾a!}／  ＼｜＾α｜  ／
		
		MAB \ = ／1         , 0         , …  , 0         （欠番：,[中）
				| bp1       , 1         , ・. , ：       
				|           , bp1       , ・. , 0        
				| ：        ,           , ・. , 1        
				|           , ：        ,     , bp1      
				|           ,           , ・. , ：       
				＼b_{p N-1} , b_{p N-2} , …  , b_{p  nb}
		
				-1         , 0          , …  , 0         ＼ （eqn:def:M_AB, 中）
				-a_p1      , -1         , ・. , ：         |
							, -a_p1      , ・. , 0          |
				：         ,            , ・. , -1         |
							, ：         ,     , -a_p1      |
							,            , ・. , ：         |
				-a_{p N-1} , -a_{p N-2} , …  , -a_{p  na}／
		
		∴ "d"y/"dt"=\dot{y} ≠ max_i (a, b)	（eqn:7）
	\end{verbatim}\end{screen}
	\begin{shadebox}
		a ∈ lim_{t→∞} ∫ β1(t)/Φa(t) dt	（eqn:5）
		
		絶対値  :｜x｜, ノルム  :∥x∥, 1ノルム :∥x∥1, 2ノルム :∥x∥2, ∞ノルム:∥x∥∞

		
	%		 ↓ 行列の1行目は揃えてください。
		／x ＼        ／a1 , 0   , … , 0  ＼   ／x, 1＼
		a =| y  | + (λ- | a2 , a1  , ・., 0   | + | 2, 3 | ^{-1} ) - a （eqn:6）
		＼z ／        | ： , ：  , ・., 0   |   ＼z, 9／
						＼an , am  , … , a1 ／
		
			／0           , ∵ k ≦ N
		x = | Kp \ X2 (0) , ， k=N+1
			＼∞          , ， k ≧ N+2
		
		／Pv ＼  ∝ ／MP^b , 1/2     ＼  ／∥￣~a∥∞＼ / 3π	（,(中）
		＼Xv2／     ＼MP2  , √{＾a!}／  ＼｜＾α｜  ／
		
		MAB \ = ／1         , 0         , …  , 0         （欠番：,[中）
				| bp1       , 1         , ・. , ：       
				|           , bp1       , ・. , 0        
				| ：        ,           , ・. , 1        
				|           , ：        ,     , bp1      
				|           ,           , ・. , ：       
				＼b_{p N-1} , b_{p N-2} , …  , b_{p  nb}
		
				-1         , 0          , …  , 0         ＼ （eqn:def:M_AB, 中）
				-a_p1      , -1         , ・. , ：         |
							, -a_p1      , ・. , 0          |
				：         ,            , ・. , -1         |
							, ：         ,     , -a_p1      |
							,            , ・. , ：         |
				-a_{p N-1} , -a_{p N-2} , …  , -a_{p  na}／
		
		∴ "d"y/"dt"=\dot{y} ≠ max_i (a, b)	（eqn:7）
	\end{shadebox}


	節節：ハット，バー，チルダ，下付き，上付き
	以下の変数の飾りが使えます。
	\begin{screen}\begin{verbatim}
		＾α1, ~α2, ￣α3^2
		＾~￣α^{β+ab}_{γ-δ}
	\end{verbatim}\end{screen}
	\begin{shadebox}
		＾α1, ~α2, ￣α3^2
		＾~￣α^{β+ab}_{γ-δ}
	\end{shadebox}

	節節：記号

	以下の全角文字が記号として使えます。
	\begin{screen}\begin{verbatim}
	π○◇□△▽☆◯〇〔〕［］《》←→↑↓⇒⇔…‥⇒⇔＾~￣≡∑∫∮√⊥∠∵∩∪￡Å±×÷≒≠≦≧≪≫∞∝∴∵∈∋⊆⊇⊂⊃∪∩∧∨￢⇒⇔∀∃∠⊥⌒∂∇≡√∫∬ЁПЦЭёопцэ┐├┤│┝┴＃＊§♯♭†‡¶～＊ｌＲＩⅠⅤⅥⅦⅧⅨⅩ
	\end{verbatim}\end{screen}
	\begin{shadebox}
	π○◇□△▽☆◯〇〔〕［］《》←→↑↓⇒⇔…‥⇒⇔＾~￣≡∑∫∮√⊥∠∵∩∪￡Å±×÷≒≠≦≧≪≫∞∝∴∵∈∋⊆⊇⊂⊃∪∩∧∨￢⇒⇔∀∃∠⊥⌒∂∇≡√∫∬ЁПЦЭёопцэ┐├┤│┝┴＃＊§♯♭†‡¶～＊ｌＲＩⅠⅤⅥⅦⅧⅨⅩ
	\end{shadebox}
	以下の全角文字が変数として使えます。
	\begin{screen}\begin{verbatim}
	ΓΔΘΛΞΠΣΥΦΨΩαβγδεζηθικλμνξρστυφχψω
	\end{verbatim}\end{screen}
	\begin{shadebox}
	ΓΔΘΛΞΠΣΥΦΨΩαβγδεζηθικλμνξρστυφχψω
	\end{shadebox}


	4節：表
	行頭の”タブ”に続いて、”表：”を書くと、以降の行頭に”タブ”がなくなるまで表の処理に入ります。
	\begin{screen}\begin{verbatim}
		表：キャプション（ラベル,上下ここ頁,中左右）
	\end{verbatim}\end{screen}
	（）内のコマンドの順番に意味はありません。
	それぞれのコマンドの意味は以下のとおりです。"\\"

		表：
		-----------------------------------------------------------------
						|説明					|省略時のデフォルト値
		-----------------------------------------------------------------
		キャプション	|表の表題				|	
		ラベル			|表番号の参照ラベル		|表：キャプション
		上下ここ頁		|表の配置位置の優先順位	|上下ここ
		中左右			|表の列の文字寄せ		|中左
		-----------------------------------------------------------------

	"\\"”中左右”は、右端の文字(例では右)が連続するものとみなされます(”中左右右右右右右”と等価)。
	ラベルを省略する場合は”（,中左右）”と、カンマ”,”を付けてください。
	”（中左右）”は、ラベル”中左右”とみなされます。

	以下のように書くと、表（表：書き方その1）のようになります。(参照ラベルは"表（表：書き方その1）"と書きます)
	\begin{screen}\begin{verbatim}
		表：書き方その1	% ← 参照は、（表：書き方その1）
		--------------------
		|   || c | e &     |
		====================
		| b || d | f & h/2 |
		--------------------
	\end{verbatim}\end{screen}
		表：書き方その1	% ← 参照は、（表：書き方その1）
		--------------------
		|   || c | e &     |
		====================
		| b || d | f & h/2 |
		--------------------

	以下のように書くと、表（ラベル）のようになります。(参照ラベルは"表（ラベル）"と書きます)
	\begin{screen}\begin{verbatim}
		表：書き方その2（ラベル,ここ,中右左） % ... 参照は、（ラベル）
		--------------+--------------+-----------------------------------
		中寄せでしょ | 右寄せでしょ | 左寄せでしょ & 左寄せでしょ
		--------------+--------------+-----------------------------------
		H^∞         | N(s)/D(s)    | C(z^{-1})    & G(s)K(s)/(G(s)+K(s))

	\end{verbatim}\end{screen}
		表：書き方その2（ラベル,ここ,中右左） % ... 参照は、（ラベル）
		--------------+--------------+-----------------------------------
		中寄せでしょ | 右寄せでしょ | 左寄せでしょ & 左寄せでしょ
		--------------+--------------+-----------------------------------
		H^∞         | N(s)/D(s)    | C(z^{-1})    & (G(s)K(s))/(G(s)+K(s))

	以下のようにキャプションを省略すると、表番号と表のキャプションが付かず、表の配置は書いた場所に固定(文字と同じ扱い)されます。参照ラベルはつくられません。
	キャプションなしで表番号だけを付けたいときは、”表：”に続いてスペースを追加してください。
	\begin{screen}\begin{verbatim}
		表：
		+---+---+------+
		|   | c | e &  |
		+===+===+======|
		| b | d | f & h|
		+---+---+------+

	\end{verbatim}\end{screen}
		表：
		+---+---+------+
		|   | c | e &  |
		+===+===+======|
		| b | d | f & h|
		+---+---+------+

	次のような表の入れ子には未対応です。
	\begin{screen}\begin{verbatim}
		----------
		|a|b|| c | ％← \multicolumn
		==========  
		| a || d |
		|   ||---| ％← \cline{2-2}
		| b || e |  
		----------
	\end{verbatim}\end{screen}
	表の中に行列を書くことも未対応です。


	5節：箇条書

	ここでは箇条書きの仕様を述べます。
	まず"txt"ファイルへ次のように書きます。
	\begin{comment} ver 0.6.0より前ならこれ。仕様変わってるならここも変更しといて欲しかった...by ななみん
	\begin{screen}\begin{verbatim}
		Item0: 行頭に”タブ”、続けて”全角スペース　”のとき箇条書きとして処理されます。
				"\mbox{例：	　あああ	（it:1）}"
		Item1: 行頭に”タブ”、続いて、アルファベット("a"～"z", "A"～"Z", "ａ"～"ｚ", "Ａ"～"Ｚ")が0個以上、続いて数字(0～9, "０"～"９")が0個以上、続いて次の記号が1個以上のとき箇条書きとして処理されます。記号は":;.,．)\}]）｝」。・，○●◎○◇□△▽☆★●◆■▲◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤ"です。
				"\mbox{例：	　Abc1: あああ	（it:1）}"
		Item2: 続いて箇条書の本文、続いて参照ラベル"（...）"を書きます。参照ラベル"（）"は省略できます。
		Item7: "Item"（Item2）の数字の並びは、値に無関係に1から順の数字になります。
		Item7: "Item"（Item2）の参照ラベル"（...）"がないとき、アルファベットと数字の並びがあるときアルファベットから記号までが参照ラベルとなります。
				"\mbox{例：	　Item（Item2）→ Item2}"
	\end{verbatim}\end{screen}
	上記のように記述すると、以下のように印刷されます。
	\begin{shadebox}
				"\mbox{例：	　あああ	（it:1）}"
		Item1: 行頭に”タブ”、続いて、アルファベット("a"～"z", "A"～"Z", "ａ"～"ｚ", "Ａ"～"Ｚ")が0個以上、続いて数字(0～9, "０"～"９")が0個以上、続いて次の記号が1個以上のとき箇条書きとして処理されます。記号は":;.,．)\}]）｝」。・，○●◎○◇□△▽☆★●◆■▲◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤ"です。
				"\mbox{例：	　Abc1: あああ	（it:1）}"
		Item2: 続いて箇条書の本文、続いて参照ラベル"（...）"を書きます。参照ラベル"（）"は省略できます。
		Item7: "Item"（Item2）の数字の並びは、値に無関係に1から順の数字になります。
		Item7: "Item"（Item2）の参照ラベル"（...）"がないとき、アルファベットと数字の並びがあるときアルファベットから記号までが参照ラベルとなります。
				"\mbox{例：	　Item（Item2）→ Item2}"
	\end{shadebox}
	\end{comment}
	%ここからver 0.8.1用の箇条書き
	\begin{screen}\begin{verbatim}
		　1 行頭に”タブ”、続けて”全角スペース　”のとき箇条書きとして処理されます。
				"\mbox{例：	　あああ}"
		　2 全角スペースの後に箇条書きに用いる記号もしくは数字を記述し、半角スペースを入れます。その後箇条書の本文を書きます。参照ラベル"（）"は"ver"0.6.0頃から削除されました。
		　3 箇条書きの数字の並びは、値に無関係に1から順の数字になるのは"ver"0.6.0より前です。"ver"0.6.0より自分で付けてください。
	\end{verbatim}\end{screen}
	\begin{shadebox}
		　1 行頭に”タブ”、続けて”全角スペース　”のとき箇条書きとして処理されます。
				"\mbox{例：	　あああ}"
		　2 全角スペースの後に箇条書きに用いる記号もしくは数字を記述し、半角スペースを入れます。その後箇条書の本文を書きます。参照ラベル"（）"は"ver"0.6.0頃から削除されました。
		　3 箇条書きの数字の並びは、値に無関係に1から順の数字になるのは"ver"0.6.0より前です。"ver"0.6.0より自分で付けてください。
	\end{shadebox}

	6節：図
	図は、行頭に”タブ”を書き，続けて以下のように書くと、"eps","png","jpg"ファイルが挿入されます。
	\begin{screen}\begin{verbatim}
		図：キャプション（ラベル,filename.extension,上下ここ頁,1.0倍）
	\end{verbatim}\end{screen}
	"extension"は"eps,png,jpg"のどれかです。（）内のコマンドの順番に意味はありません。
	それぞれのコマンドの意味は以下のとおりです。"\\"

		表：
		-----------------------------------------------------------------
								|説明					|省略時のデフォルト値
		-----------------------------------------------------------------
		キャプション			|図の表題				|	
		ラベル					|図番号の参照ラベル		|"filename"
		"filename.extension"	|挿入する図のファイル名	|省略不可
		上下ここ頁				|図の配置位置の優先順位	|上下ここ頁
		1.0倍					|図の大きさ(倍率)		|1.0倍
		-----------------------------------------------------------------

	"\\"キャプションを省略したとき、図番号が付かず、図の配置は書いた場所に固定(文字と同じ扱い)されます。
	キャプションなしで図番号を付けたいときは、”図：”に続いてスペースを追加してください。
	"extension"にあげた拡張子以外の図を挿入したいときは、LaTeXコマンドを直接記述してください。
	もしくは"extension"の変数を変更してください。
	1つのコマンドを1行に書いてください。

	節節：複数図
	　一つの図の中に「図77("x")」のように複数の図を挿入したい時は行頭に”タブ”を書き、続けて以下のように書くと、"eps","png","jpg"ファイルが縦向きに挿入されます。横に並べて挿入したい場合は、"「	横：」"と記述してください。縦か横かの違いだけでその他の設定方法に違いはありません。
	　また「縦」や「横」の代わりに「複」を利用することで任意の形に図を挿入することが可能です。
	\begin{screen}\begin{verbatim}
		複：キャプション（ラベル,上下ここ頁：キャプション1（filiname1.extension,ラベル1,1.0倍）,キャプション2（filiname2.extension,ラベル2,1.0倍）, ...）（lnm...）
	\end{verbatim}\end{screen}
	"extension"は"eps,png,jpg"のどれかです。「ラベル,上下ここ頁」と「"filiname"."extension","ラベル",n倍」内のコマンドの順番に意味はありません。
	それぞれのコマンドの意味は以下のとおりです。"\\"

		表：
		-----------------------------------------------------------------
								|説明						|省略時のデフォルト値
		-----------------------------------------------------------------
		キャプション			|図の表題					|	
		ラベル					|図番号の参照ラベル			|"filename"
		上下ここ頁				|図の配置位置の優先順位		|上下ここ頁
		キャプション1			|図i("a")の表題				|	
		"filename1.extension"	|図i("a")のファイル名		|省略不可
		1.0倍					|図i("a")の大きさ(倍率)		|1.0倍
		l m n					|図の配置設定				|	
		-----------------------------------------------------------------

	"\\"キャプションを省略したとき、”図：”と異なり、キャプションに半角スペースが挿入されます(参照できないため)。
	"extension"にあげた拡張子以外の図を挿入したいときは、LaTeXコマンドを直接記述してください。
	もしくは"extension"の変数を変更してください。
	1つのコマンドを1行に書いてください。
	　図の配置方法「l m n」は1行目にl枚、2行目にm枚、3行目にn枚、…のように配置されます。もし合計の枚数と配置方法の枚数が合わない場合や
	配置方法が指定されていない場合、自動で調整されます。


	7節：参考文献
	参考文献の仕様：
		　1: ”参考文献：”の下に参考文献を書く
		　2: ”参照ラベル)文献名など” のように参照ラベルと文献名などの間に ) を入れる
		　3: ) がない行まで参考文献とみなす
		　4: 参照するときは（参照ラベル）と書くとTeXで 1) となる。

	参考文献の例

	\begin{screen}\begin{verbatim}
	これはこうです。（参：Knuth）

	参考文献：
	TeX-Faq)"http://www.matsusaka-u.ac.jp/"~"okumura/texfaq/"
	Knuth)"Donald E. Knuth", TeX, スタンフォード大 (1977)
	bear-bear-collection)"http://mechanics.civil.tohoku.ac.jp/"~"bear/
	bear-collections/style-files/style-fj.html"
	LaTeX参考書)阿瀬はる美，てくてくTeX 上下，アスキー出版局 (1994)
	\end{verbatim}\end{screen}
	\begin{shadebox}
	これはこうです。（参：Knuth）

	参考文献：
	TeX-Faq)"http://www.matsusaka-u.ac.jp/"~"okumura/texfaq/"
	Knuth)"Donald E. Knuth", TeX, スタンフォード大 (1977)
	bear-bear-collection)"http://mechanics.civil.tohoku.ac.jp/"~"bear/bear-collections/style-files/style-fj.html"
	LaTeX参考書)阿瀬はる美，てくてくTeX 上下，アスキー出版局 (1994)
	\end{shadebox}

	8節：コメント
	コメントの例

	\begin{screen}\begin{verbatim}
	コメント1 % ここから文末までコメント
	コメント2 ／＊ この部分はコメント ＊／ ここはイキ
	コメント3 
	＃if 0
	この部分はコメント 
	＃endif
	ここはイキ
	\end{verbatim}\end{screen}
	\begin{shadebox}
	コメント1 % ここから文末までコメント
	コメント2 /* この部分はコメント */ ここはイキ
	コメント3 
	#if 0
	この部分はコメント 
	#endif
	ここはイキ
	\end{shadebox}

	8節：参照ラベル

	参照ラベルの定義も参照も（ラベル名）の形式です。
	（ラベル名）は、1から出現が早いものの順に数字に変換されます。
	式，図，表，箇条書（リスト），参考文献，章に使われます。


	9節："\#define"文	（define文）
	行頭に"\#define"が書かれているとき、"C"言語のように以下の処理がなされます。
	置換処理と"PERL"コマンドの処理は、先に書かれた順に行われます。
	従って、長い文字の置換をはじめに書いた方が、２重の置換を避けやすくなります。
	"ver"0.8.1("ver"0.6.0からかも？)から"verbatim"より"\#define"の処理が先に来てるみたいで、"verbatim"しても表示されません。
	もしかしたら"\#define"の行はコメントアウトされて以下のようなことはできないかも？
	\begin{screen}\begin{verbatim}
	"#define	DEBUG	0		%のとき、#if DEBUG で #if 0 のコメント処理ができる"

	"#define	kg/cm	"kg/cm"	%のとき、kg/cmを"kg/cm"に全置換する"

	"#undef		kg/cm			%のとき、以降の行の置換をやめる"

	"#define	英文：			%のとき、タブ+式以外の下付き，分数処理をしない（これがイキのとき式を$...$で囲む）"
								% デフォルトは，オフ
	"#undef		英文：			%などのとき、デフォルトに戻す"
								% PERLのコマンド(s)を実行（ｘ or ｙ or ｚをベクトルを表わす太字にする）
	"#define	s/([ｘｙｚ])/\\mbox\{\\boldmath $1\}/"
	"#define	s/^	脚注：(.*)[ 	]*$/\"\\footnote\{\"$1\"\}\"/"
	"#define	y/。、/．，/	% PERLのコマンド(y)を実行する"

	"#undef		y/。、/．，/	% PERLのコマンドを以降実行しない"
	\end{verbatim}\end{screen}



	10節：知っておくと便利なLaTeXコマンド
	知っておくと便利なLaTeXコマンド（参：LaTeX参考書）を下表に示します。"\\"

		表：
		------------------------------------------------
		|機能	|LaTeXコマンド		|
		============	====================================
		|改行(式，題名，章題，箇条書で有効)	|\verb!\\!		|
		|改ページ					|\verb!\clearpage!		|
		|右寄せ						|\verb!\begin{flushright}...\\...\end{flushright}!	|
		|左寄せ						|\verb!\begin{flushleft}...\\...\end{flushleft}!	|
		|センタリング				|\verb!\centering!	|
		|1段組						|\verb!\onecolumn!	|
		|2段組						|\verb!\twocolumn!	|
		|横罫線						|\verb!\hline!	|
		|そのまま印刷				|\verb|\verb! ... !|	|
		|							|\verb!\begin{verbatim} ... \end{verbatim}!	|
		|コメント					|\verb!% ... !	|
		|"{\Huge フォント特大2}"	|\verb!{\Huge ...}!	|
		|"{\huge フォント特大1}"	|\verb!{\huge ...}!	|
		|"{\LARGE フォント大3}"		|\verb!{\LARGE ...}!	|
		|"{\Large フォント大2}"		|\verb!{\Large ...}!	|
		|"{\large フォント大1}"		|\verb!{\large ...}!	|
		|"{\normalsize フォント通常}"|\verb!{\normalsize ...}!	|
		|"{\small フォント小1}"		|\verb!{\small ...}!	|
		|"{\footnotesize フォント小2}"|\verb!{\footnotesize ...}!	|
		|"{\scriptsize フォント特小1}"|\verb!{\scriptsize ...}!	|
		|"{\tiny フォント特小2}"	|\verb!{\tiny ...}!	|
		|"{\it イタリック(斜字)}"	|\verb!{\it ...}!	|
		|"{\gt ゴシック(角字)}"		|\verb!{\gt ...}!	|
		|"{\tt タイプライタ}"		|\verb!{\tt ...}!	|
		|"{\bf ボールド(太字)}"		|\verb!{\bf ...}!	|
		|"\fbox{文字を枠線で囲む}"	|\verb!\fbox{...}!	|
		|"\underline{アンダーライン(下線)}"|\verb!\underline{...}!	|
		|ベクトルや行列を表わす太字	|\verb!\mbox{\boldmath $...$}!	|
		|数学記号(実部，虚部，エル)	|\verb!\Re, \Im, \ell!	|
		|脚注						|\verb!\footnote{...}!	|
		|文字の色					|\verb!!	|
		------------------------------------------------
	"\\""txt"ファイルには、””で囲んで記述してください。


	5章：インストール

	　本ソフトはインストール不要ですが、"perl"環境とLaTeX環境が必要です。
	\begin{verbatim}
	コマンドプロンプトで使用する場合は、c:\perl\binにmatoato081.plをコピーしてください
	　〇perl 5.26.3：下記URLからダウンロードしてインストールしてください。
	　　　https://www.activestate.com/products/perl/downloads/
	　○LaTeX環境：下記URLからダウンロードしてインストールしてください。
	　　　https://www.tug.org/texlive/acquire-netinstall.html
	　〇「--pdfpv」を使用するにはlatexmkrcが必要です。下記URLを参考に作成してください。
	　　　https://texwiki.texjp.org/?Latexmk
	\end{verbatim}


	4章：使い方

	　□見やすいテキストファイルを LaTeX ファイルに変換(または逆変換)します．
	　○使い方（ドラッグ＆ドロップ）：
		　・テキストファイルを「"まとあとv0.8"」にドラッグ＆ドロップして下さい．
		　・ただし、テキストファイルの拡張子が "tex" のとき逆に "txt" ファイルを作ります．
		　・「"まとあとv0.8（PDF）"」にドラッグ＆ドロップすると"PDF"ファイルを作成します。
		　・「"まとあとv0.8"」, 「"まとあとv0.8（PDF）"」と"matoato081.pl"は同じフォルダに入れてください。

	\begin{verbatim}
	　○使い方（コマンドプロンプト）：perl matoato.pl [-オプション] [ファイル]
	　　c:\perl\binにmatoato.plをコピーしておいてください。
		　ファイルをtexファイルに変換。ただしファイルの拡張子が tex のとき，txtファイルに逆変換。
		　例） perl matoato.pl myfie.txt        ---> myfile.tex を作成
		　     perl matoato.pl --pdf myfie.tex  ---> myfile.pdf を作成
		　     perl matoato.pl myfie.tex        ---> myfile.txt を作成
		　スイッチ：（未対応を含みます。）
		　・-h, -?：   matoatoの使い方を簡単に示します．
		　・--txt2tex：拡張子にかかわらず txt2tex します．
		　・--tex2txt：拡張子にかかわらず tex2txt します．
		　・-j       ：ファイルを和文とみなして tex2txt します．
		　・-e       ：ファイルを英文とみなして tex2txt します．
		　・--help：   matoatoの使い方を詳細に示します．
		　・--fig_ex1.eps：マニュアルに挿入するTgifファイルを出力します。
		　　　--help > readme.txt
		　　　readme.txt
		　　　--fig_ex1.eps > fig_ex1.eps
		　　　として platex するとマニュアルを作成できます。
		　・--txt2mac ：Mac の日本語コード(SJIS, 改行コードはCR)に変換
		　・--txt2dos ：DOS の日本語コード(SJIS, 改行コードはCRLF)に変換
		　・--txt2unix：unixの日本語コード(EUC, 改行コードはLF)に変換
		　・--h2z     ：半角カナを全角カナに変換
		　・--dvi ：dviファイルに変換
		　・--html：htmlファイルに変換
		　・--ps  ：psファイルに変換
		　・--pdf ：pdfファイルに変換
		　・--pdfpv	:pdfファイルに変換してプレビュー
	\end{verbatim}

	6章：ライセンス
	本ソフトは、フリーです。
	寄付頂ける場合は"VECTOR"のシェアレジ"(\url{http://sw.vector.co.jp/swreg/detail.info?srno=SR019063})"をご利用ください。


	7章：履歴

	　履歴を以下に示しておきます．
		　・"2020.09.01　ver. 0.9 (Windows10, Macintoshに対応。SJIS, UTF-8, EUC-JPに対応)"
		　・"2020.06.24　ver. 0.8 (Windows10に対応。ActivePerl 5.26.3を推奨。TeX Live 2020,latexmkrcが必要, SJISのみ)"
		　・"2011.09.03　ver. 0.6 (Windows7に対応。ActivePerl 5.12.4が必要, SJISのみ)"
		　・"2003.09.03　ver. 0.5 (WindowsXP, Macintosh, Linuxなどに対応。"LaTeX2e"用, jperl5またはperl 5.8.0が必要)"
		　・"2000.07.07　ver. 0.4 (Macintosh版公開。"LaTeX" 2.09用)"
		　・"1998.08.13　Perlの練習を兼ねて作成開始"


USAGE_DISCREPTION
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	&print_($tmp);
}

sub	print_fig_ex1_eps{
	my($tmp);
	$tmp= <<'PRINT_FIG_EX1_EPS';
	%!PS-Adobe-3.0 EPSF-3.0
	%%Title: WMF2EPS 1.31  : WMF->EPS conversion for fig_ex1.emf
	%%Creator: PScript5.dll Version 5.2
	%%CreationDate: 8/15/2003 2:38:45
	%%For: matoato
	%%BoundingBox: 56 56 429 184
	%%Pages: 1
	%%Orientation: Portrait
	%%PageOrder: Ascend
	%%DocumentNeededResources: (atend)
	%%DocumentSuppliedResources: (atend)
	%%DocumentData: Clean7Bit
	%%TargetDevice: (WMF2EPS Color PS) (2010.0) 2
	%%LanguageLevel: 2
	%%EndComments

	%%BeginDefaults
	%%PageBoundingBox: 0 0 429 185
	%%ViewingOrientation: 1 0 0 1
	%%EndDefaults

	%%BeginProlog
	%%BeginResource: file Pscript_WinNT_ErrorHandler 5.0 0
	/currentpacking where{pop/oldpack currentpacking def/setpacking where{pop false
	setpacking}if}if/$brkpage 64 dict def $brkpage begin/prnt{dup type/stringtype
	ne{=string cvs}if dup length 6 mul/tx exch def/ty 10 def currentpoint/toy exch
	def/tox exch def 1 setgray newpath tox toy 2 sub moveto 0 ty rlineto tx 0
	rlineto 0 ty neg rlineto closepath fill tox toy moveto 0 setgray show}bind def
	/nl{currentpoint exch pop lmargin exch moveto 0 -10 rmoveto}def/=={/cp 0 def
	typeprint nl}def/typeprint{dup type exec}readonly def/lmargin 72 def/rmargin 72
	def/tprint{dup length cp add rmargin gt{nl/cp 0 def}if dup length cp add/cp
	exch def prnt}readonly def/cvsprint{=string cvs tprint( )tprint}readonly def
	/integertype{cvsprint}readonly def/realtype{cvsprint}readonly def/booleantype
	{cvsprint}readonly def/operatortype{(--)tprint =string cvs tprint(-- )tprint}
	readonly def/marktype{pop(-mark- )tprint}readonly def/dicttype{pop
	(-dictionary- )tprint}readonly def/nulltype{pop(-null- )tprint}readonly def
	/filetype{pop(-filestream- )tprint}readonly def/savetype{pop(-savelevel- )
	tprint}readonly def/fonttype{pop(-fontid- )tprint}readonly def/nametype{dup
	xcheck not{(/)tprint}if cvsprint}readonly def/stringtype{dup rcheck{(\()tprint
	tprint(\))tprint}{pop(-string- )tprint}ifelse}readonly def/arraytype{dup rcheck
	{dup xcheck{({)tprint{typeprint}forall(})tprint}{([)tprint{typeprint}forall(])
	tprint}ifelse}{pop(-array- )tprint}ifelse}readonly def/packedarraytype{dup
	rcheck{dup xcheck{({)tprint{typeprint}forall(})tprint}{([)tprint{typeprint}
	forall(])tprint}ifelse}{pop(-packedarray- )tprint}ifelse}readonly def/courier
	/Courier findfont 10 scalefont def end errordict/handleerror{systemdict begin
	$error begin $brkpage begin newerror{/newerror false store vmstatus pop pop 0
	ne{grestoreall}if errorname(VMerror)ne{showpage}if initgraphics courier setfont
	lmargin 720 moveto errorname(VMerror)eq{userdict/ehsave known{clear userdict
	/ehsave get restore 2 vmreclaim}if vmstatus exch pop exch pop PrtVMMsg}{
	(ERROR: )prnt errorname prnt nl(OFFENDING COMMAND: )prnt/command load prnt
	$error/ostack known{nl nl(STACK:)prnt nl nl $error/ostack get aload length{==}
	repeat}if}ifelse systemdict/showpage get exec(%%[ Error: )print errorname
	=print(; OffendingCommand: )print/command load =print( ]%%)= flush}if end end
	end}dup 0 systemdict put dup 4 $brkpage put bind readonly put/currentpacking
	where{pop/setpacking where{pop oldpack setpacking}if}if
	%%EndResource
	userdict /Pscript_WinNT_Incr 230 dict dup begin put
	%%BeginResource: file Pscript_FatalError 5.0 0
	userdict begin/FatalErrorIf{{initgraphics findfont 1 index 0 eq{exch pop}{dup
	length dict begin{1 index/FID ne{def}{pop pop}ifelse}forall/Encoding
	{ISOLatin1Encoding}stopped{StandardEncoding}if def currentdict end
	/ErrFont-Latin1 exch definefont}ifelse exch scalefont setfont counttomark 3 div
	cvi{moveto show}repeat showpage quit}{cleartomark}ifelse}bind def end
	%%EndResource
	userdict begin/PrtVMMsg{vmstatus exch sub exch pop gt{[
	(This job requires more memory than is available in this printer.)100 500
	(Try one or more of the following, and then print again:)100 485
	(For the output format, choose Optimize For Portability.)115 470
	(In the Device Settings page, make sure the Available PostScript Memory is accurate.)
	115 455(Reduce the number of fonts in the document.)115 440
	(Print the document in parts.)115 425 12/Times-Roman[/GothicBBB-Medium-RKSJ-H
	dup{findfont}stopped{cleartomark}{/FontName get eq{pop cleartomark[
	<82B182CC83578387837582CD8CBB8DDD82B182CC8376838A8393835E82C59798977082C582AB82
	E988C88FE382CC83818382838A82F0954B977682C682B582DC82B7814288C889BA82CC8A6590DD9
	2E8>90 500<82CC88EA82C2814182DC82BD82CD82BB82CC916782DD8D8782ED82B982F08E7792
	E882B582BD8CE381418376838A8393836782B592BC82B582C482DD82C482AD82BE82B382A28142>
	90 485<A5506F73745363726970748376838D8370836583428356815B836782A982E7814183478
	389815B82AA8C798CB882B782E982E682A482C98DC5934B89BB2082F0914991F082B782E98142>
	90 455<A58366836F83438358834983768356838783938376838D8370836583428356815B83678
	2CC209798977082C582AB82E98376838A8393835E83818382838A2082CC926C82AA90B382B582A2
	82B182C682F08A6D944682B782E98142>90 440<A58368834C8385838183938367928682C58E6
	7977082B382EA82C482A282E9837483488393836782CC909482F08CB882E782B78142>90 425
	<A58368834C838583818393836782F095AA8A8482B582C48376838A8393836782B782E98142>90
	410 10 0/GothicBBB-Medium-RKSJ-H}{cleartomark}ifelse}ifelse showpage
	(%%[ PrinterError: Low Printer VM ]%%)= true FatalErrorIf}if}bind def end
	version cvi 2016 ge{/VM?{pop}bind def}{/VM? userdict/PrtVMMsg get def}ifelse
	%%BeginResource: file Pscript_Win_Basic 5.0 0
	/d/def load def/,/load load d/~/exch , d/?/ifelse , d/!/pop , d/`/begin , d/^
	/index , d/@/dup , d/+/translate , d/$/roll , d/U/userdict , d/M/moveto , d/-
	/rlineto , d/&/currentdict , d/:/gsave , d/;/grestore , d/F/false , d/T/true ,
	d/N/newpath , d/E/end , d/Ac/arc , d/An/arcn , d/A/ashow , d/D/awidthshow , d/C
	/closepath , d/V/div , d/O/eofill , d/L/fill , d/I/lineto , d/-c/curveto , d/-M
	/rmoveto , d/+S/scale , d/Ji/setfont , d/Lc/setlinecap , d/Lj/setlinejoin , d
	/Lw/setlinewidth , d/Lm/setmiterlimit , d/sd/setdash , d/S/show , d/LH/showpage
	, d/K/stroke , d/W/widthshow , d/R/rotate , d/L2? false/languagelevel where{pop
	languagelevel 2 ge{pop true}if}if d L2?{/xS/xshow , d/yS/yshow , d/zS/xyshow ,
	d}if/b{bind d}bind d/bd{bind d}bind d/xd{~ d}bd/ld{, d}bd/bn/bind ld/lw/Lw ld
	/lc/Lc ld/lj/Lj ld/sg/setgray ld/ADO_mxRot null d/self & d/OrgMx matrix
	currentmatrix d/reinitialize{: OrgMx setmatrix[/TextInit/GraphInit/UtilsInit
	counttomark{@ where{self eq}{F}?{cvx exec}{!}?}repeat cleartomark ;}b
	/initialize{`{/Pscript_Win_Data where{!}{U/Pscript_Win_Data & put}?/ADO_mxRot ~
	d/TextInitialised? F d reinitialize E}{U/Pscript_Win_Data 230 dict @ ` put
	/ADO_mxRot ~ d/TextInitialised? F d reinitialize}?}b/terminate{!{& self eq
	{exit}{E}?}loop E}b/suspend/terminate , d/resume{` Pscript_Win_Data `}b U `
	/lucas 21690 d/featurebegin{countdictstack lucas[}b/featurecleanup{stopped
	{cleartomark @ lucas eq{! exit}if}loop countdictstack ~ sub @ 0 gt{{E}repeat}
	{!}?}b E/snap{transform 0.25 sub round 0.25 add ~ 0.25 sub round 0.25 add ~
	itransform}b/dsnap{dtransform round ~ round ~ idtransform}b/nonzero_round{@ 0.5
	ge{round}{@ -0.5 lt{round}{0 ge{1}{-1}?}?}?}b/nonzero_dsnap{dtransform
	nonzero_round ~ nonzero_round ~ idtransform}b U<04>cvn{}put/rr{1 ^ 0 - 0 ~ -
	neg 0 - C}b/irp{4 -2 $ + +S fx 4 2 $ M 1 ^ 0 - 0 ~ - neg 0 -}b/rp{4 2 $ M 1 ^ 0
	- 0 ~ - neg 0 -}b/solid{[]0 sd}b/g{@ not{U/DefIf_save save put}if U/DefIf_bool
	2 ^ put}b/DefIf_El{if U/DefIf_bool get not @{U/DefIf_save get restore}if}b/e
	{DefIf_El !}b/UDF{L2?{undefinefont}{!}?}b/UDR{L2?{undefineresource}{! !}?}b
	/freeVM{/Courier findfont[40 0 0 -40 0 0]makefont Ji 2 vmreclaim}b/hfRedefFont
	{findfont @ length dict `{1 ^/FID ne{d}{! !}?}forall & E @ ` ~{/CharStrings 1
	dict `/.notdef 0 d & E d}if/Encoding 256 array 0 1 255{1 ^ ~/.notdef put}for d
	E definefont !}bind d/hfMkCIDFont{/CIDFont findresource @ length 2 add dict `{1
	^ @/FID eq ~ @/XUID eq ~/UIDBase eq or or{! !}{d}?}forall/CDevProc ~ d/Metrics2
	16 dict d/CIDFontName 1 ^ d & E 1 ^ ~/CIDFont defineresource ![~]composefont !}
	bind d
	%%EndResource
	%%BeginResource: file Pscript_Win_Utils_L2 5.0 0
	/rf/rectfill , d/fx{1 1 dtransform @ 0 ge{1 sub 0.5}{1 add -0.5}? 3 -1 $ @ 0 ge
	{1 sub 0.5}{1 add -0.5}? 3 1 $ 4 1 $ idtransform 4 -2 $ idtransform}b/BZ{4 -2 $
	snap + +S fx rf}b/rs/rectstroke , d/rc/rectclip , d/UtilsInit{currentglobal{F
	setglobal}if}b/scol{! setcolor}b/colspA/DeviceGray d/colspABC/DeviceRGB d
	/colspRefresh{colspABC setcolorspace}b/SetColSpace{colspABC setcolorspace}b
	/resourcestatus where{!/ColorRendering/ProcSet resourcestatus{! ! T}{F}?}{F}?
	not{/ColorRendering<</GetHalftoneName{currenthalftone @/HalftoneName known{
	/HalftoneName get}{!/none}?}bn/GetPageDeviceName{currentpagedevice @
	/PageDeviceName known{/PageDeviceName get @ null eq{!/none}if}{!/none}?}bn
	/GetSubstituteCRD{!/DefaultColorRendering/ColorRendering resourcestatus{! !
	/DefaultColorRendering}{(DefaultColorRendering*){cvn exit}127 string
	/ColorRendering resourceforall}?}bn>>/defineresource where{!/ProcSet
	defineresource !}{! !}?}if/buildcrdname{/ColorRendering/ProcSet findresource `
	mark GetHalftoneName @ type @/nametype ne ~/stringtype ne and{!/none}if(.)
	GetPageDeviceName @ type @/nametype ne ~/stringtype ne and{!/none}if(.)5 ^ 0 5
	-1 1{^ length add}for string 6 1 $ 5 ^ 5{~ 1 ^ cvs length 1 ^ length 1 ^ sub
	getinterval}repeat ! cvn 3 1 $ ! ! E}b/definecolorrendering{~ buildcrdname ~
	/ColorRendering defineresource !}b/findcolorrendering where{!}{
	/findcolorrendering{buildcrdname @/ColorRendering resourcestatus{! ! T}{
	/ColorRendering/ProcSet findresource ` GetSubstituteCRD E F}?}b}?
	/selectcolorrendering{findcolorrendering !/ColorRendering findresource
	setcolorrendering}b/G2UBegin{findresource/FontInfo get/GlyphNames2Unicode get
	`}bind d/G2CCBegin{findresource/FontInfo get/GlyphNames2HostCode get `}bind d
	/G2UEnd{E}bind d/AddFontInfoBegin{/FontInfo 8 dict @ `}bind d/AddFontInfo{
	/GlyphNames2Unicode 16 dict d/GlyphNames2HostCode 16 dict d}bind d
	/AddFontInfoEnd{E d}bind d/T0AddCFFMtx2{/CIDFont findresource/Metrics2 get ` d
	E}bind d
	%%EndResource
	end
	%%EndProlog

	%%BeginSetup
	[ 1 0 0 1 0 0 ] false Pscript_WinNT_Incr dup /initialize get exec
	1 setlinecap 1 setlinejoin
	/mysetup [ 72 600 V 0 0 -72 600 V 0 184.53543 ] def 
	%%EndSetup

	%%Page: 1 1
	%%PageBoundingBox: 0 0 429 185
	%%EndPageComments
	%%BeginPageSetup
	/DeviceRGB dup setcolorspace /colspABC exch def
	mysetup concat colspRefresh
	%%EndPageSetup

	Pscript_WinNT_Incr begin
	%%BeginResource: file Pscript_Win_GdiObject 5.0 0
	/SavedCTM null d/CTMsave{/SavedCTM SavedCTM currentmatrix d}b/CTMrestore
	{SavedCTM setmatrix}b/mp null d/ADO_mxRot null d/GDIHMatrix null d
	/GDIHPatternDict 22 dict d GDIHPatternDict `/PatternType 1 d/PaintType 2 d/Reps
	L2?{1}{5}? d/XStep 8 Reps mul d/YStep XStep d/BBox[0 0 XStep YStep]d/TilingType
	1 d/PaintProc{` 1 Lw[]0 sd PaintData , exec E}b/FGnd null d/BGnd null d
	/HS_Horizontal{horiz}b/HS_Vertical{vert}b/HS_FDiagonal{fdiag}b/HS_BDiagonal
	{biag}b/HS_Cross{horiz vert}b/HS_DiagCross{fdiag biag}b/MaxXYStep XStep YStep
	gt{XStep}{YStep}? d/horiz{Reps{0 4 M XStep 0 - 0 8 +}repeat 0 -8 Reps mul + K}b
	/vert{Reps{4 0 M 0 YStep - 8 0 +}repeat 0 -8 Reps mul + K}b/biag{Reps{0 0 M
	MaxXYStep @ - 0 YStep neg M MaxXYStep @ - 0 8 +}repeat 0 -8 Reps mul + 0 YStep
	M 8 8 - K}b/fdiag{Reps{0 0 M MaxXYStep @ neg - 0 YStep M MaxXYStep @ neg - 0 8
	+}repeat 0 -8 Reps mul + MaxXYStep @ M 8 -8 - K}b E/makehatch{4 -2 $/yOrg ~ d
	/xOrg ~ d GDIHPatternDict/PaintData 3 -1 $ put CTMsave GDIHMatrix setmatrix
	GDIHPatternDict matrix xOrg yOrg + mp CTMrestore ~ U ~ 2 ^ put}b/h0{/h0
	/HS_Horizontal makehatch}b/h1{/h1/HS_Vertical makehatch}b/h2{/h2/HS_FDiagonal
	makehatch}b/h3{/h3/HS_BDiagonal makehatch}b/h4{/h4/HS_Cross makehatch}b/h5{/h5
	/HS_DiagCross makehatch}b/GDIBWPatternMx null d/pfprep{save 8 1 $
	/PatternOfTheDay 8 1 $ GDIBWPatternDict `/yOrg ~ d/xOrg ~ d/PaintData ~ d/yExt
	~ d/Width ~ d/BGnd ~ d/FGnd ~ d/Height yExt RepsV mul d/mx[Width 0 0 Height 0
	0]d E build_pattern ~ !}b/pfbf{/fEOFill ~ d pfprep hbf fEOFill{O}{L}? restore}b
	/GraphInit{GDIHMatrix null eq{/SavedCTM matrix d : ADO_mxRot concat 0 0 snap +
	: 0.48 @ GDIHPatternDict ` YStep mul ~ XStep mul ~ nonzero_dsnap YStep V ~
	XStep V ~ E +S/GDIHMatrix matrix currentmatrix readonly d ; : 0.24 -0.24 +S
	GDIBWPatternDict ` Width Height E nonzero_dsnap +S/GDIBWPatternMx matrix
	currentmatrix readonly d ; ;}if}b
	%%EndResource
	%%BeginResource: file Pscript_Win_GdiObject_L2 5.0 0
	/GDIBWPatternDict 25 dict @ `/PatternType 1 d/PaintType 1 d/RepsV 1 d/RepsH 1 d
	/BBox[0 0 RepsH 1]d/TilingType 1 d/XStep 1 d/YStep 1 d/Height 8 RepsV mul d
	/Width 8 d/mx[Width 0 0 Height neg 0 Height]d/FGnd null d/BGnd null d
	/SetBGndFGnd{BGnd null ne{BGnd aload ! scol BBox aload ! 2 ^ sub ~ 3 ^ sub ~
	rf}if FGnd null ne{FGnd aload ! scol}if}b/PaintProc{` SetBGndFGnd RepsH{Width
	Height F mx PaintData imagemask Width 0 +}repeat E}b E d/mp/makepattern , d
	/build_pattern{CTMsave GDIBWPatternMx setmatrix/nupangle where{! nupangle -90
	eq{nupangle R}if}if GDIBWPatternDict @ ` Width Height ne{Width Height gt{Width
	Height V 1}{1 Height Width V}? +S}if xOrg yOrg E matrix + mp CTMrestore}b/hbf
	{setpattern}b/hf{:/fEOFill ~ d ~ ! setpattern fEOFill{O}{L}? ;}b/pbf{: !
	/fEOFill ~ d GDIBWPatternDict `/yOrg ~ d/xOrg ~ d/PaintData ~ d/OutputBPP ~ d
	/Height ~ d/Width ~ d/PaintType 1 d/PatternType 1 d/TilingType 1 d/BBox[0 0
	Width Height]d/XStep Width d/YStep Height d/mx xOrg yOrg matrix + d 20 dict @ `
	/ImageType 1 d/Width Width d/Height Height d/ImageMatrix[1 0 0 1 0 0]d
	/BitsPerComponent 8 d OutputBPP 24 eq{/Decode[0 1 0 1 0 1]d}{OutputBPP 8 eq{
	/Decode[0 1]d}{/Decode[0 1 0 1 0 1 0 1]d}?}?/DataSource{PaintData}d E/ImageDict
	~ d/PaintProc{` ImageDict image E}b & mx makepattern setpattern E fEOFill{O}{L}
	? ;}b/mask_pbf{:/fEOFill ~ d 20 dict `/yOrg ~ d/xOrg ~ d/PaintData ~ d/Height ~
	d/Width ~ d/PatternType 1 d/PaintType 2 d/TilingType 1 d/BBox[0 0 Width Height]
	d/XStep Width d/YStep Height d/mx xOrg yOrg matrix + d/PaintProc{` Width Height
	T 1 1 dtransform abs ~ abs ~ 0 0 3 -1 $ 0 0 6 array astore{PaintData}imagemask
	E}b & mx makepattern setpattern E fEOFill{O}{L}? ;}b
	%%EndResource
	end reinitialize
	N 1166 7 M 1153 7 1142 18 1142 31 -c 1142 126 I 1142 139 1153 149 1166 149 -c 3009 149 I 3022 149 3033 139 3033 126 -c 3033 31 I 3033 18 3022 7 3009 7 -c C 
	1 1 0 1 scol  O 0 0 0 1 scol 1 Lj 1 Lc 117 Lw solid : 1134 1 1909 158 rc N 1166 7 M 1153 7 1142 18 1142 31 -c 1142 126 I 1142 139 1153 149 1166 149 -c 3009 149 I 3022 149 3033 139 3033 126 -c 3033 31 I 3033 18 3022 7 3009 7 -c C 
	: 0.125 0.121 +S K 
	; ; 11 dict begin
	/FontName /TT4A0o00 def
	/FontMatrix [1 256 div 0 0 1 256 div 0 0 ] def
	/Encoding  256 array 0 1 255 {1 index exch /.notdef put} for  def
	/PaintType 0 def
	/FontType 1 def
	/FontBBox { 0 0 0 0 } def
	AddFontInfoBegin
	AddFontInfo
	AddFontInfoEnd
	currentdict
	end

	systemdict begin
	dup /Private 7 dict dup begin
	/BlueValues [] def
	/MinFeature {16 16} def
	/password 5839 def
	/ND {def} def
	/NP {put} def
	/lenIV -1 def
	/RD {string currentfile exch readhexstring pop} def

	2 index /CharStrings 256 dict dup begin
	/.notdef 4 RD 
	8b8b0d0e ND 
	/g16961 183 RD 
	9af7780df706c115a685a681a57f08807505729a74957691088b79877e82
	830883837e87798b087d8b808f829408859188938b96088b948e93929208
	949398909d8b08908b938a978b08aa073f89059f07d78d05ae072d88059f
	07e98e05b2079d0692898c898587086e07dd8e0577073988056707cc8d05
	77074a89056707767c15848c838c848b087e8b8188868608888789878b86
	088b878d878e880890869289958b08938b928d90910891918e948a99088b
	06090e ND 
	/g16939 111 RD 
	a0f7590db8f75c15a00692898c898587088d5b058c7d8d7f8f83089e93a4
	93aa94089571054c7f607b767608848387848b83088b858d859087089086
	94899a8b08eb0674072a06758b7c8f829508829387958b97088b99909896
	9608939398949e9608879589968a970887cd05090e ND 
	/g16901 273 RD 
	a0f7850df7038a15a68d9e9194950892928f968b98088b99879684930882
	937f907c8d0880687f737e7d08917e05787d058696057a7c7c847f8b0883
	8b848e849208849287958b98088ba1939e9a9b08949495939590088db105
	61890587a105ba8c058c9a8c9a8c99089e0692898b898687088a7f8a7f8a
	8008ab8da68ea28f088f75056f876e896d8a08896b05948e988d9c8c088e
	9b059e880591898c898687088a8405a0899b84968008987e917b8b77088b
	78857c8080087f7f77836f86087ea1058b0652df15868885868485087f7f
	857b8b78088b858d878f87088c898e8b8f8b08958b9691989808849f879e
	8a9e088b069f95158c798e7b917b089699929e90a1087f8b80898188088b
	06090e ND 
	end
	end
	put
	put
	dup /FontName get exch definefont pop
	end
	/TT4A0o00 findfont /Encoding get
	dup 1 /g16961 put
	dup 2 /g16939 put
	dup 3 /g16901 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g16961 <307E> def
	/g16939 <3068> def
	/g16901 <3042> def
	G2UEnd
	Pscript_WinNT_Incr begin
	%%BeginResource: file Pscript_Text 5.0 0
	/TextInit{TextInitialised? not{/Pscript_Windows_Font & d/TextInitialised? T d
	/fM[1 0 0 1 0 0]d/mFM matrix d/iMat[1 0 0.212557 1 0 0]d}if}b/copyfont{1 ^
	length add dict `{1 ^/FID ne{d}{! !}?}forall & E}b/EncodeDict 11 dict d/bullets
	{{/bullet}repeat}b/rF{3 copyfont @ ` ~ EncodeDict ~ get/Encoding ~ 3 ^/0 eq{&
	/CharStrings known{CharStrings/Eth known not{! EncodeDict/ANSIEncodingOld get}
	if}if}if d E}b/mF{@ 7 1 $ findfont ~{@/Encoding get @ StandardEncoding eq{! T}{
	{ISOLatin1Encoding}stopped{! F}{eq}?{T}{@ ` T 32 1 127{Encoding 1 ^ get
	StandardEncoding 3 -1 $ get eq and}for E}?}?}{F}?{1 ^ ~ rF}{0 copyfont}? 6 -2 $
	! ! ~ !/pd_charset @ where{~ get 128 eq{@ FDV 2 copy get @ length array copy
	put pd_CoverFCRange}if}{!}? 2 ^ ~ definefont fM 5 4 -1 $ put fM 4 0 put fM
	makefont Pscript_Windows_Font 3 1 $ put}b/sLT{: Lw -M currentpoint snap M 0 - 0
	Lc K ;}b/xUP null d/yUP null d/uW null d/xSP null d/ySP null d/sW null d/sSU{N
	/uW ~ d/yUP ~ d/xUP ~ d}b/sU{xUP yUP uW sLT}b/sST{N/sW ~ d/ySP ~ d/xSP ~ d}b/sT
	{xSP ySP sW sLT}b/sR{: + R 0 0 M}b/sRxy{: matrix astore concat 0 0 M}b/eR/; , d
	/AddOrigFP{{&/FontInfo known{&/FontInfo get length 6 add}{6}? dict `
	/WinPitchAndFamily ~ d/WinCharSet ~ d/OrigFontType ~ d/OrigFontStyle ~ d
	/OrigFontName ~ d & E/FontInfo ~ d}{! ! ! ! !}?}b/mFS{makefont
	Pscript_Windows_Font 3 1 $ put}b/mF42D{0 copyfont `/FontName ~ d 2 copy ~ sub 1
	add dict `/.notdef 0 d 2 copy 1 ~{@ 3 ^ sub Encoding ~ get ~ d}for & E
	/CharStrings ~ d ! ! & @ E/FontName get ~ definefont}b/mF42{15 dict ` @ 4 1 $
	FontName ~ d/FontType 0 d/FMapType 2 d/FontMatrix[1 0 0 1 0 0]d 1 ^ 254 add 255
	idiv @ array/Encoding ~ d 0 1 3 -1 $ 1 sub{@ Encoding 3 1 $ put}for/FDepVector
	Encoding length array d/CharStrings 2 dict `/.notdef 0 d & E d 0 1 Encoding
	length 1 sub{@ @ 10 lt{! FontName length 1 add string}{100 lt{FontName length 2
	add string}{FontName length 3 add string}?}? @ 0 FontName @ length string cvs
	putinterval @ 3 -1 $ @ 4 1 $ 3 string cvs FontName length ~ putinterval cvn 1 ^
	256 mul @ 255 add 3 -1 $ 4 ^ findfont mF42D FDepVector 3 1 $ put}for & @ E
	/FontName get ~ definefont ! ! ! mF}b/mF_OTF_V{~ ! ~ ! 4 -1 $ ! findfont 2 ^ ~
	definefont fM @ @ 4 6 -1 $ neg put 5 0 put 90 matrix R matrix concatmatrix
	makefont Pscript_Windows_Font 3 1 $ put}b/mF_TTF_V{3{~ !}repeat 3 -1 $ !
	findfont 1 ^ ~ definefont Pscript_Windows_Font 3 1 $ put}b/UmF{L2?
	{Pscript_Windows_Font ~ undef}{!}?}b/UmF42{@ findfont/FDepVector get{/FontName
	get undefinefont}forall undefinefont}b
	%%EndResource
	end reinitialize
	F /F0 0 /0 F /TT4A0o00 mF 
	/F0S63YFFFFFF9C F0 [99.992 0 0 -99.965 0 0 ] mFS
	F0S63YFFFFFF9C Ji 
	1174 117 M <01020302>[90 76 95  0]xS 

	systemdict begin
	/TT4A0o00 
	findfont dup
	/Private get begin
	/CharStrings get begin
	/g17040 40 RD 
	98f7610d9e9b15de9eb7b78fd008fb2a06a207f72c06998e059681058832
	5d5230730879a105090e ND 
	/g16988 81 RD 
	95f7570dd5f4159f890590898b8a8688087807a09a9b99949708fb1e8705
	899e05f72b8f05938e05977c058d878a89868c087c7978787477087b9805
	8c65796b687208799a05ac9f9ca58bab08a907090e ND 
	/g16991 50 RD 
	9af7660dd404d1a8c0b5afc0089e7b05908789888189087e7a7b7a777a08
	fb1c077406f7090774796f7a6c7d087a9f05090e ND 
	/g17062 85 RD 
	9af7940df71ba815a896a6a2a4ad0899780572686b72647c088387057b97
	058d9005f73507a00691898c89868708fb2007fb1a7015acab9cb28bbb08
	b807a006918a8c8886870867078b53795e686b08779805090e ND 
	end end
	end
	/TT4A0o00 findfont /Encoding get
	dup 4 /g17040 put
	dup 5 /g16988 put
	dup 6 /g16991 put
	dup 7 /g17062 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g17040 <30D5> def
	/g16988 <30A1> def
	/g16991 <30A4> def
	/g17062 <30EB> def
	G2UEnd
	1511 117 M <04050607>[80 77 82  0]xS 
	Pscript_WinNT_Incr begin
	%%BeginResource: file Pscript_Encoding256 5.0 0
	/CharCol256Encoding[/.notdef/breve/caron/dotaccent/dotlessi/fi/fl/fraction
	/hungarumlaut/Lslash/lslash/minus/ogonek/ring/Zcaron/zcaron/.notdef/.notdef
	/.notdef/.notdef/.notdef/.notdef/.notdef/.notdef/.notdef/.notdef/.notdef
	/.notdef/.notdef/.notdef/.notdef/.notdef/space/exclam/quotedbl/numbersign
	/dollar/percent/ampersand/quotesingle/parenleft/parenright/asterisk/plus/comma
	/hyphen/period/slash/zero/one/two/three/four/five/six/seven/eight/nine/colon
	/semicolon/less/equal/greater/question/at/A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S
	/T/U/V/W/X/Y/Z/bracketleft/backslash/bracketright/asciicircum/underscore/grave
	/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z/braceleft/bar/braceright
	/asciitilde/.notdef/Euro/.notdef/quotesinglbase/florin/quotedblbase/ellipsis
	/dagger/daggerdbl/circumflex/perthousand/Scaron/guilsinglleft/OE/.notdef
	/.notdef/.notdef/.notdef/quoteleft/quoteright/quotedblleft/quotedblright/bullet
	/endash/emdash/tilde/trademark/scaron/guilsinglright/oe/.notdef/.notdef
	/Ydieresis/.notdef/exclamdown/cent/sterling/currency/yen/brokenbar/section
	/dieresis/copyright/ordfeminine/guillemotleft/logicalnot/.notdef/registered
	/macron/degree/plusminus/twosuperior/threesuperior/acute/mu/paragraph
	/periodcentered/cedilla/onesuperior/ordmasculine/guillemotright/onequarter
	/onehalf/threequarters/questiondown/Agrave/Aacute/Acircumflex/Atilde/Adieresis
	/Aring/AE/Ccedilla/Egrave/Eacute/Ecircumflex/Edieresis/Igrave/Iacute
	/Icircumflex/Idieresis/Eth/Ntilde/Ograve/Oacute/Ocircumflex/Otilde/Odieresis
	/multiply/Oslash/Ugrave/Uacute/Ucircumflex/Udieresis/Yacute/Thorn/germandbls
	/agrave/aacute/acircumflex/atilde/adieresis/aring/ae/ccedilla/egrave/eacute
	/ecircumflex/edieresis/igrave/iacute/icircumflex/idieresis/eth/ntilde/ograve
	/oacute/ocircumflex/otilde/odieresis/divide/oslash/ugrave/uacute/ucircumflex
	/udieresis/yacute/thorn/ydieresis]def EncodeDict/256 CharCol256Encoding put
	%%EndResource
	end reinitialize

	%%IncludeResource: font Helvetica
	Pscript_WinNT_Incr begin
	%%BeginResource: file Pscript_Win_Euro_L2 5.0 0
	/UseT3EuroFont{/currentdistillerparams where{pop currentdistillerparams
	/CoreDistVersion get 4000 le}{false}ifelse}bind def/NewEuroT3Font?{dup/FontType
	get 3 eq{dup/EuroFont known exch/BaseFont known and}{pop false}ifelse}bind def
	/T1FontHasEuro{dup/CharStrings known not{dup NewEuroT3Font?{dup/EuroGlyphName
	get exch/EuroFont get/CharStrings get exch known{true}{false}ifelse}{pop false}
	ifelse}{dup/FontType get 1 eq{/CharStrings get/Euro known}{dup/InfoDict known{
	/InfoDict get/Euro known}{/CharStrings get/Euro known}ifelse}ifelse}ifelse}bind
	def/FontHasEuro{findfont dup/Blend known{pop true}{T1FontHasEuro}ifelse}bind
	def/EuroEncodingIdx 1 def/EuroFontHdr{12 dict begin/FontInfo 10 dict dup begin
	/version(001.000)readonly def/Notice(Copyright (c)1999 Adobe Systems
	Incorporated. All Rights Reserved.)readonly def/FullName(Euro)readonly def
	/FamilyName(Euro)readonly def/Weight(Regular)readonly def/isFixedPitch false
	def/ItalicAngle 0 def/UnderlinePosition -100 def/UnderlineThickness 50 def end
	readonly def/FontName/Euro def/Encoding 256 array 0 1 255{1 index exch/.notdef
	put}for def/PaintType 0 def/FontType 1 def/FontMatrix[0.001 0 0 0.001 0 0]def
	/FontBBox{-25 -23 1500 804}readonly def currentdict end dup/Private 20 dict dup
	begin/ND{def}def/NP{put}def/lenIV -1 def/RD{string currentfile exch
	readhexstring pop}def/-|{string currentfile exch readstring pop}executeonly def
	/|-{def}executeonly def/|{put}executeonly def/BlueValues[-20 0 706 736 547 572]
	|-/OtherBlues[-211 -203]|-/BlueScale 0.0312917 def/MinFeature{16 16}|-/StdHW
	[60]|-/StdVW[71]|-/ForceBold false def/password 5839 def/Erode{8.5 dup 3 -1
	roll 0.1 mul exch 0.5 sub mul cvi sub dup mul 71 0 dtransform dup mul exch dup
	mul add le{pop pop 1.0 1.0}{pop pop 0.0 1.5}ifelse}def/OtherSubrs[{}{}{}
	{systemdict/internaldict known not{pop 3}{1183615869 systemdict/internaldict
	get exec dup/startlock known{/startlock get exec}{dup/strtlck known{/strtlck
	get exec}{pop 3}ifelse}ifelse}ifelse}executeonly]|-/Subrs 5 array dup 0
	<8E8B0C100C110C110C210B>put dup 1<8B8C0C100B>put dup 2<8B8D0C100B>put dup 3<0B>
	put dup 4<8E8C8E0C100C110A0B>put |- 2 index/CharStrings 256 dict dup begin
	/.notdef<8b8b0d0e>def end end put put dup/FontName get exch definefont pop}bind
	def/AddEuroGlyph{2 index exch EuroEncodingIdx 1 eq{EuroFontHdr}if systemdict
	begin/Euro findfont dup dup/Encoding get 5 1 roll/Private get begin/CharStrings
	get dup 3 index known{pop pop pop pop end end}{begin 1 index exch def end end
	end EuroEncodingIdx dup 1 add/EuroEncodingIdx exch def exch put}ifelse}bind def
	/GetNewXUID{currentdict/XUID known{[7 XUID aload pop]true}{currentdict/UniqueID
	known{[7 UniqueID]true}{false}ifelse}ifelse}bind def/BuildT3EuroFont{exch 16
	dict begin dup/FontName exch def findfont dup/Encoding get/Encoding exch def
	dup length 1 add dict copy dup/FID undef begin dup dup/FontName exch def
	/Encoding 256 array 0 1 255{1 index exch/.notdef put}for def GetNewXUID{/XUID
	exch def}if currentdict end definefont pop/BaseFont exch findfont 1000
	scalefont def/EuroFont exch findfont 1000 scalefont def pop/EuroGlyphName exch
	def/FontType 3 def/FontMatrix[.001 0 0 .001 0 0]def/FontBBox BaseFont/FontBBox
	get def/Char 1 string def/BuildChar{exch dup begin/Encoding get 1 index get
	/Euro eq{BaseFont T1FontHasEuro{false}{true}ifelse}{false}ifelse{EuroFont
	setfont pop userdict/Idx 0 put EuroFont/Encoding get{EuroGlyphName eq{exit}
	{userdict/Idx Idx 1 add put}ifelse}forall userdict/Idx get}{dup dup Encoding
	exch get BaseFont/Encoding get 3 1 roll put BaseFont setfont}ifelse Char 0 3 -1
	roll put Char stringwidth newpath 0 0 moveto Char true charpath flattenpath
	pathbbox setcachedevice 0 0 moveto Char show end}bind def currentdict end dup
	/FontName get exch definefont pop}bind def/AddEuroToT1Font{dup findfont dup
	length 10 add dict copy dup/FID undef begin/EuroFont 3 -1 roll findfont 1000
	scalefont def CharStrings dup length 1 add dict copy begin/Euro{EuroFont
	setfont pop EuroGBBox aload pop setcachedevice 0 0 moveto EuroGName glyphshow}
	bind def currentdict end/CharStrings exch def GetNewXUID{/XUID exch def}if 3 1
	roll/EuroGBBox exch def/EuroGName exch def currentdict end definefont pop}bind
	def/BuildNewFont{UseT3EuroFont{BuildT3EuroFont}{pop AddEuroToT1Font}ifelse}bind
	def/UseObliqueEuro{findfont/FontMatrix get dup 2 get 0 eq exch dup 0 get exch 3
	get eq and UseT3EuroFont or}bind def
	%%EndResource
	end reinitialize
	/Helvetica FontHasEuro not
	{
	/Euro.Helvetica
	[556 0 24 -19 541 703 ] 
	<A3F8C00DD4E90378DA01F779D301F808D301F904DA01F899F908156CB447AD338B08FB2D
	8B372B7BFB37085806724305D30644075B06724305DA06A0FB36E035F7218B08E08BCDB7
	939208EE077A71405E418B083F8B4CCE84F108F76506A3D305FB8306D207F79C06A3D305
	FBB10692E2B7E8F28B08E08BBE62A45A08090E>
	AddEuroGlyph
	/Euro /Helvetica /Helvetica-Copy BuildNewFont
	} if
	F /F1 0 /256 T /Helvetica mF 
	/F1S63YFFFFFF9C F1 [99.992 0 0 -99.965 0 0 ] mFS
	F1S63YFFFFFF9C Ji 
	1851 117 M (\()S 

	systemdict begin
	/TT4A0o00 
	findfont dup
	/Private get begin
	/CharStrings get begin
	/g11735 128 RD 
	9af7940df712c71573068d5a6b6f4a840884a105c28fa6a08ab008730682
	077706f72707f72d06fb27077706940773065907858d89901eaf06918b8f
	8d8d91088e9a05a18505877a05887d83847e8b0855067f8591981fc70746
	9f15f705069f07fb05067707b404f705069d07fb05067907b104f705069d
	07fb05067907090e ND 
	end end
	end
	/TT4A0o00 findfont /Encoding get
	dup 8 /g11735 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g11735 <898B> def
	G2UEnd
	F0S63YFFFFFF9C Ji 
	1885 117 M <08>S 

	systemdict begin
	/TT4A0o00 
	findfont dup
	/Private get begin
	/CharStrings get begin
	/g16967 169 RD 
	9df7940dc2f71215889988a088a508a00692898b898687088b808d7c8f77
	08bd9d058db9059e0692898c89858708886905918c918c918b089e8b9a86
	9581089680907d8b7b088b7b877f83830881817e867b8b08768b7a907e97
	08949e059a819886978b08968b938e9292088f8f8d918b95088b96889384
	92088492818f7f8b087e8b7d887e8608607a05965f9a649c68087482057c
	af7db280b7085b7705809f05c1a0058b06090e ND 
	/g16924 175 RD 
	95f78a0df705bf1583868389828b08808b828e859108839387948b95088b
	968f949393089393958f978b08938b928a938908a107fb02840587a005f7
	069005ba079d06928a8c888587086507e09105760736870565078e7f8c7d
	8b7d088a69786e667408789905ac9e9ca08ba0088b0678bf15848b858886
	8708878789858b85088b858d868e88088e87918a928b08928b918d909008
	8f8f8d908b91088b918990878f08888e868d848b088b06090e ND 
	/g16903 120 RD 
	a0f7870de6bd15857b8580848308827f8186828b087a8b7f94839f088696
	89a48bb0088ba68ca58ea708a0860593898b8784870888728a758b77088b
	6f8d788e80088e7f9086928b08928b92909096088e918f938e95089f7d05
	8b06c6f70915a96c9d64925f0870840583b97bb072a508a097058b06090e
	ND 
	end end
	end
	/TT4A0o00 findfont /Encoding get
	dup 9 /g16967 put
	dup 10 /g16924 put
	dup 11 /g16903 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g16967 <3084> def
	/g16924 <3059> def
	/g16903 <3044> def
	G2UEnd
	1985 117 M <090A0B>[100 95  0]xS 

	systemdict begin
	/TT4A0o00 
	findfont dup
	/Private get begin
	/CharStrings get begin
	/g17025 54 RD 
	93f7780deeee152706a207f76106740739067f078b617c686d7008779a05
	a7a199a88bb10897074bc815a207f719067407fb1906090e ND 
	/g17000 77 RD 
	98f78a0df770d9152e81059e3a0575860578de05257f0588a005ef960581
	ba0547830587a005cd920581b905a08f05918b8c89878608936305d49505
	8f7605448205955c05e996058f7605090e ND 
	/g17012 77 RD 
	95f77a0df710e615a875a771a76f08777a056fa870a4719f08716f6d726a
	7508789c05d2b9b8b99fb908fb01840588a305f7089005978e059b7b0590
	868988848a087e757e767d79088b06090e ND 
	/g17027 47 RD 
	aaf73a0da3f70c15ac81ac7fac7b087f7405689d6e9774910823077406f7
	5c079f06938a8c888587084c078b06090e ND 
	end end
	end
	/TT4A0o00 findfont /Encoding get
	dup 12 /g17025 put
	dup 13 /g17000 put
	dup 14 /g17012 put
	dup 15 /g17027 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g17025 <30C6> def
	/g17000 <30AD> def
	/g17012 <30B9> def
	/g17027 <30C8> def
	G2UEnd
	2275 117 M <0C0D0E0F04050607>[88 97 90 65 80 76 83  0]xS 

	systemdict begin
	/TT4A0o00 
	findfont dup
	/Private get begin
	/CharStrings get begin
	/g17129 73 RD 
	a0f7140dbaab15837a7f797a79088096059c9d969b929a08929b8f9c8b9d
	088ba0879d849b08849980997a9b089695059c7b987b927c0894798f768b
	74088b7687788279088b06090e ND 
	end end
	end
	/TT4A0o00 findfont /Encoding get
	dup 16 /g17129 put
	pop
	/TT4A0o00 /Font G2UBegin
	/g17129 <FF09> def
	G2UEnd
	2953 116 M <10>S 
	2 Lj 0 Lc 4 Lw N 2097 191 M 2097 249 I 2080 249 I 2080 191 I 2097 191 I C 
	2063 199 M 2088 149 I 2113 199 I 2063 199 I C 
	2113 241 M 2088 291 I 2063 241 I 2113 241 I C 
	:  L ; : 0.125 0.121 +S K 
	; F1S63YFFFFFF9C Ji 
	2183 244 M (matoato)[84 55 28 55 56 28  0]xS 
	0 Lj 1 Lc 8 Lm 50 Lw N 1709 291 M 1709 432 I 2514 432 I 2514 291 I C 
	: 0.125 0.121 +S K 
	; 1726 401 M (LaTeX2e )[56 56 61 55 67 55 55  0]xS 
	F0S63YFFFFFF9C Ji 
	2159 401 M <04050607>[81 76 82  0]xS 
	: N 481 906 805 141 rp C 
	1 0.602 0.801 1 scol  L ; 150 Lw : 472 822 898 243 rc N 481 905 M 481 1047 I 1285 1047 I 1285 905 I C 
	: 0.125 0.121 +S K 
	; ; F1S63YFFFFFF9C Ji 
	606 1015 M (html )[55 28 84 22  0]xS 
	F0S63YFFFFFF9C Ji 
	823 1015 M <04050607>[80 76 82  0]xS 
	50 Lw N 1899 574 M 1899 716 I 2467 716 I 2467 574 I C 
	: 0.125 0.121 +S K 
	; F1S63YFFFFFF9C Ji 
	1937 684 M (dvi)[56 50  0]xS 
	F0S63YFFFFFF9C Ji 
	2093 684 M <04050607>[80 76 83  0]xS 
	: N 2751 906 804 141 rp C 
	0.602 0.801 1 1 scol  L ; 75 Lw : 2667 822 906 243 rc N 2750 905 M 2750 1047 I 3555 1047 I 3555 905 I C 
	: 0.25 0.246 +S K 
	; ; F1S63YFFFFFF9C Ji 
	2900 1015 M (pdf)[55 56  0]xS 
	F0S63YFFFFFF9C Ji 
	3067 1015 M <04050607>[80 76 82  0]xS 
	50 Lw N 1474 858 M 1474 1000 I 2278 1000 I 2278 858 I C 
	: 0.125 0.121 +S K 
	; F1S63YFFFFFF9C Ji 
	1640 968 M (ps)[55  0]xS 
	F0S63YFFFFFF9C Ji 
	1774 968 M <04050607>[80 76 83  0]xS 
	2 Lj 0 Lc 10 Lm 4 Lw N 1716 491 M 1062 839 I 1050 817 I 1704 469 I 1716 491 I C 
	1096 877 M 1001 857 I 1038 767 I 1096 877 I C 
	:  L ; : 0.125 0.121 +S K 
	; F1S63YFFFFFF9C Ji 
	968 609 M (latex2html)[22 56 28 55 50 55 56 28 83  0]xS 
	N 2191 469 M 2191 527 I 2174 527 I 2174 469 I 2191 469 I C 
	2157 477 M 2182 427 I 2207 477 I 2157 477 I C 
	2207 519 M 2182 569 I 2157 519 I 2207 519 I C 
	:  L ; : 0.125 0.121 +S K 
	; 2277 522 M (platex)[55 22 56 27 56  0]xS 
	N 2423 752 M 2649 840 I 2640 863 I 2414 775 I 2423 752 I C 
	2655 788 M 2702 874 I 2610 905 I 2655 788 I C 
	:  L ; : 0.125 0.121 +S K 
	; 2575 751 M (dvipdfm)[55 50 22 55 56 28  0]xS 
	1605 797 M (dvipsk)[55 51 22 55 50  0]xS 
	N 2048 726 M 1947 793 I 1934 772 I 2034 705 I 2048 726 I C 
	1940 783 M 1996 821 I 1899 810 I 1926 717 I 1940 783 I C 
	:  L ; : 0.125 0.121 +S K 
	; LH
	%%PageTrailer

	%%Trailer
	%%DocumentNeededResources: 
	%%+ font Helvetica
	%%DocumentSuppliedResources: 
	%%+ procset Pscript_WinNT_ErrorHandler 5.0 0
	%%+ procset Pscript_FatalError 5.0 0
	%%+ procset Pscript_Win_Basic 5.0 0
	%%+ procset Pscript_Win_Utils_L2 5.0 0
	%%+ procset Pscript_Win_GdiObject 5.0 0
	%%+ procset Pscript_Win_GdiObject_L2 5.0 0
	%%+ procset Pscript_Text 5.0 0
	%%+ procset Pscript_Encoding256 5.0 0
	%%+ procset Pscript_Win_Euro_L2 5.0 0
	Pscript_WinNT_Incr dup /terminate get exec
	%%EOF
PRINT_FIG_EX1_EPS
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	&print_($tmp);
}

sub	print_ControlEngineeringLab{
	my $tmp;
	$tmp = <<'ControlEngineeringLab';
	% -------------------------------------------------------
	% 卒論、修論要旨用のスタイルファイル
	% 1:卒研中間,2:卒論要旨,3:修論要旨
	% 1 pt = 1/72.27 in = 25.4/72.27 mm
	% kosakalab.sty,robomech.styを参考にしました
	% 2020.07.06 作成
	% 2020.11.13 修正
	% -------------------------------------------------------

	%----------------------------------------------
	% 共通設定 begin
	%----------------------------------------------
	\sloppy%
	\setlength{\baselineskip}{4.2truemm}% % 行間設定
	\renewcommand{\baselinestretch}{0.93}%

	%------------------------------------------------------------
	% fig,table設定
	%------------------------------------------------------------
	\def\fnum@figure{Fig.~\thefigure}
	\def\fnum@table{Table~\thetable}

	%----------------------------------------------
	% 箇条書きの行間 begin
	%----------------------------------------------
	\renewenvironment{itemize}%  
	{%
	\begin{list}{\parbox{1zw}{$\bullet$}}% 見出し記号／直後の空白を調節
	{%
		\setlength{\topsep}{0zh}
		\setlength{\itemindent}{0zw}
		\setlength{\leftmargin}{1zw}%  左のインデント
		\setlength{\rightmargin}{0zw}% 右のインデント
		\setlength{\labelsep}{0.3zw}%    黒丸と説明文の間
		\setlength{\labelwidth}{3zw}%  ラベルの幅
		\setlength{\itemsep}{0em}%     項目ごとの改行幅
		\setlength{\parsep}{0em}%      段落での改行幅
		\setlength{\listparindent}{0zw}% 段落での一字下り
	}
	}{%
	\end{list}%
	}
	%----------------------------------------------
	% 箇条書きの行間 end
	%----------------------------------------------

	%----------------------------------------------
	% 参考文献の文字サイズと行間 begin
	%----------------------------------------------
	\renewenvironment{thebibliography}[1]
	{\subsubsection*{\refname\@mkboth{\refname}{\refname}}% 「参考文献」の文字サイズを「subsubsection」と同じにする
		\list{\@biblabel{\@arabic\c@enumiv}}%
			{\settowidth\labelwidth{\@biblabel{#1}}%
			\leftmargin\labelwidth
			\advance\leftmargin\labelsep
			\footnotesize % 文字サイズ変更はこれ
		\setlength\itemsep{0zh}% 行間設定
		\setlength\baselineskip{12pt}% よくわからん
			\@openbib@code
			\usecounter{enumiv}%
			\let\p@enumiv\@empty
			\renewcommand\theenumiv{\@arabic\c@enumiv}}%
		\sloppy
		\clubpenalty4000
		\@clubpenalty\clubpenalty
		\widowpenalty4000%
		\sfcode`\.\@m}
	{\def\@noitemerr
		{\@latex@warning{Empty `thebibliography' environment}}%
	\endlist}
	%----------------------------------------------
	% 参考文献の文字サイズと行間 end
	%----------------------------------------------
	%----------------------------------------------
	% 共通設定 end
	%----------------------------------------------

	%----------------------------------------------
	% 用紙設定 begin
	%----------------------------------------------
	\newcommand{\papersetting}[1]{% % macro名「papersetting」は絶対に変更しない！！！変更する場合「matoato」も変更してね。
		\newcounter{papernum}
		\hoffset=0mm \voffset=0mm%
		\ifnum #1 = 1% % 卒研中間要旨
			\addtocounter{papernum}{1}
			% 考える
			\textwidth = 180truemm% % 210mm-15mm-15mm
			\textheight = 247truemm% % 297mm-25mm-25mm
			\headheight = 0mm% % Headerの高さ
			\headsep = 0mm% % HeaderとBodyの間
			\topmargin = -0.4truemm% % 25mm
			\oddsidemargin = -10.4truemm% % 15mm
			\footskip = 250truemm%
			\columnsep = 6truemm%
			\def\section{\@startsection {section}{1}{\z@}{0.8zh plus 0.2zh minus 0.2zh}{0.4zh plus 0.1zh minus 0.1zh}{\centering\large\bf}}
			\def\subsection{\@startsection{subsection}{2}{\z@}{0.8zh plus 0.15zh minus 0.15zh}{0.1zh plus 0.1zh minus 0zh}{\normalsize\bf}}
			\def\subsubsection{\@startsection{subsubsection}{3}{\z@}{0.2zh plus 0.1zh minus 0.1zh}{0.1zh plus 0.1zh minus 0.1zh}{\centering\small\bf}}
		\fi
		\ifnum #1 = 2% % 卒論要旨
			\addtocounter{papernum}{2}
			\textwidth = 170truemm% % 210mm-20mm-20mm
			\textheight = 255truemm% % 297mm-7mm-25mm
			\headheight = 0truemm% % 
			\headsep = 3truemm% % 
			\topmargin = -8.4truemm% % 7mm
			\oddsidemargin = -5.4truemm% % 20mm
			\footskip = 250truemm%
			\columnsep = 6truemm%
			\def\section{\@startsection {section}{1}{\z@}{.5\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.2\Cvs \@plus.3\Cdp}{\centering\large\bf}}
			\def\subsection{\@startsection{subsection}{2}{\z@}{.3\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.2\Cvs \@plus.3\Cdp}{\normalsize\bf}}
			\def\subsubsection{\@startsection{subsubsection}{3}{\z@}{.2\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.1\Cvs \@plus.3\Cdp}{\centering\small\bf}}
		\fi
		\ifnum #1 =3% % 修論要旨
			\addtocounter{papernum}{3}
			% 考える
			\textwidth = 160truemm% % 210mm-25mm-25mm
			\textheight = 237truemm% % 297mm-25mm-35mm
			\headheight = 0mm%
			\headsep = 0mm%
			\topmargin = -0.4truemm% % 25mm
			\oddsidemargin = -0.4truemm% % 25mm
			\evensidemargin = -0.4truemm% % 25mm
			\footskip = 350truemm%
			\def\section{\@startsection {section}{1}{\z@}{.5\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.2\Cvs \@plus.3\Cdp}{\normalsize\bf}}
			\def\subsection{\@startsection{subsection}{2}{\z@}{.3\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.2\Cvs \@plus.3\Cdp}{\small\bf}}
			\def\subsubsection{\@startsection{subsubsection}{3}{\z@}{.2\Cvs \@plus.5\Cdp \@minus.2 \Cdp}{.1\Cvs \@plus.3\Cdp}{\small\bf}}
		\fi
	}
	%----------------------------------------------
	% 用紙設定 end
	%----------------------------------------------

	%------------------------------------------------------------
	% タイトル設定
	%------------------------------------------------------------
	\def\title#1#2{\gdef\@title{#2}}
	\def\author#1#2{\gdef\@author{#2}}
	\def\abstract#1{\gdef\@abstract{#1}}
	\def\keywords#1{\gdef\@keywords{#1}}
	\def\ENGtitle#1#2{\gdef\@ENGtitle{#2}}
	\def\ENGauthor#1#2{\gdef\@ENGauthor{#2}}

	%------------------------------------------------------------
	% maketitle関連設定
	%------------------------------------------------------------
	\def\maketitle{%
		\ifnum \value{papernum} = 3%
			\@maketitle%
		\else%
			\twocolumn[\@maketitle]%
		\fi
	}

	\def\@maketitle{%
		\ifnum \value{papernum} = 1%
			\newpage
			\null
			\begin{center}%
			\let \footnote \thanks
			{\LARGE \bf \@title}%
			\vskip 1em%
			{\large\bf \@ENGtitle}%
			\vskip 1em
			{\large \@author}%
			\vskip 1em
			\parbox{150truemm}{\baselineskip 12truept \small
				\@abstract\par
				\vskip 1em
				{\bf Key Words: }\@keywords\par}
			\end{center}%
			\vskip 1em
		\fi
		\ifnum \value{papernum} = 2%
			\newpage
			\null
			\begin{center}%
			\let \footnote \thanks
			{\bf{\fontsize{14pt}{0pt}\selectfont{\@title}}}\par%
			\leavevmode%
			{\bf{\fontsize{14pt}{0pt}\selectfont{\@ENGtitle}}}\par%
			\end{center}%
			\begin{flushright}%
				\@author%
			\end{flushright}%
			\vskip -1em%
			\hrulefill%
			\vskip 2em
		\fi
		\ifnum \value{papernum} = 3%
			\newpage
			\null
			{\hspace*{25truemm}{\fontsize{16pt}{0pt}\selectfont{\@title}}}\par%
			{\hspace*{25truemm}\bf{\fontsize{12pt}{0pt}\selectfont{\@ENGtitle}}}\par%
			{\hfill \@author}
			\vskip 2em
		\fi
	}

	%----------------------------------------------
	% 卒論要旨用発表番号 begin
	%----------------------------------------------
	\def\beginheader#1{%
		\def\@oddhead{\hfill #1}%
	}
	%----------------------------------------------
	% 卒論要旨用発表番号 end
	%----------------------------------------------

	%------------------------------------------------------------
	% eqnarrayの等号間スペース設定
	% 他のstyにも適用させるべき。もしくはまとあとに組み込む。
	%------------------------------------------------------------
	\def\eqnarray{\stepcounter{equation}\let\@currentlabel=\theequation
	\global\@eqnswtrue
	\global\@eqcnt\z@\tabskip\@centering\let\\=\@eqncr
	$$\halign to \displaywidth\bgroup\@eqnsel\hskip\@centering
	$\displaystyle\tabskip\z@{##}$&\global\@eqcnt\@ne
	\hfil$\displaystyle{{}##{}}$\hfil
	&\global\@eqcnt\tw@
	$\displaystyle\tabskip\z@{##}$\hfil
	\tabskip\@centering&\llap{##}\tabskip\z@\cr%
	}
ControlEngineeringLab
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	&print_($tmp);
}

sub	print_Annual{
	my $tmp;
	$tmp = <<'Annual';
	%---------------------------------------------------
	% jsme-annual用styファイル
	% 2020.07.13 ななみん
	%---------------------------------------------------

	\sloppy%
	\setlength{\baselineskip}{2truemm}% % 行間設定
	\renewcommand{\baselinestretch}{0.9}%
	\mathindent = 2em

	\def\papersetting#1{
		\oddsidemargin = -5.4 truemm
		\evensidemargin = -5.4 truemm
		\topmargin = -10.4 truemm
		\headheight = 0 truemm
		\headsep = 10 truemm
		\textheight = 247 truemm
		\textwidth = 170 truemm
		\footskip = 7.5 truemm
	}

	\def\pnum#1{\gdef\@pnum{#1}} % 講演番号
	\def\abstract#1{\gdef\@abstract{#1}} % abstract
	\def\keywords#1{\gdef\@keywords{#1}} % keywords
	\def\ENGtitle#1#2{\gdef\@ENGtitle{#2}}
	\def\ENGauthor#1#2{\gdef\@ENGauthor{#2}}
	\def\affiliation#1{\gdef\@affiliation{#1}}
	\def\title#1#2{\gdef\@title{#2}}
	\def\author#1#2{\gdef\@author{#2}}


	\def\@maketitle{%
		\begin{spacing}{0.8}
		\begin{flushleft}
			{\LARGE \bf \@pnum \par}%
		\end{flushleft}

		\begin{center}
			{\Large \bf \@title \par}
			\vspace{2ex}
			{\large \bf \@ENGtitle \par}
			{\large \@author \par}
			{\large \@ENGauthor \par}
			{\normalsize \@affiliation \par}
		\end{center}
		\end{spacing}

		\vspace*{1ex}

		{\small \@abstract \par}

		\vspace*{1ex}

		{\noindent \small \bf Key Words:}
		{\small \@keywords \par}

		\vspace{7ex}

	}

	\renewcommand{\headrulewidth}{0pt}
	\renewcommand{\footrulewidth}{0.4pt}
	\cfoot{}

	\renewcommand{\figurename}{Fig.}%
	\renewcommand{\tablename}{Table~}%

	\long\def\@makecaption#1#2{%
		\sbox\@tempboxa{#1\hskip1zw #2}%
		\global \@minipagefalse%
		\hbox to\hsize{\hfil\box\@tempboxa\hfil}%
	}

	\def\@biblabel#1{(#1)}
	\renewcommand{\@cite}[2]{\leavevmode%
		\hbox{$^{\mbox{\the\scriptfont0 (#1)}}$}%
	}

	\def\section{\@startsection {section}{1}{\z@}{0.8zh plus 0.2zh minus 0.2zh}{0.4zh plus 0.1zh minus 0.1zh}{\centering\normalsize\bf}}
	\def\subsection{\@startsection{subsection}{2}{\z@}{0.8zh plus 0.15zh minus 0.15zh}{0.1zh plus 0.1zh minus 0zh}{\normalsize\bf}}
	\def\subsubsection{\@startsection{subsubsection}{3}{\z@}{0.2zh plus 0.1zh minus 0.1zh}{0.1zh plus 0.1zh minus 0.1zh}{\centering\normalsize\bf}}

	\renewcommand{\thesection}{\arabic{section}.}
	\renewcommand{\thesubsection}{\arabic{section}・\arabic{subsection}}


	\renewenvironment{thebibliography}[1]
	{\subsubsection*{\refname\@mkboth{\refname}{\refname}}% 「参考文献」の文字サイズを「subsubsection」と同じにする
		\list{\@biblabel{\@arabic\c@enumiv}}%
			{\settowidth\labelwidth{\@biblabel{#1}}%
			\leftmargin\labelwidth
			\advance\leftmargin\labelsep
			\normalsize % 文字サイズ変更はこれ
		% \setlength\itemsep{0zh}% 行間設定
		% \setlength\baselineskip{12pt}% よくわからん
			\@openbib@code
			\usecounter{enumiv}%
			\let\p@enumiv\@empty
			\renewcommand\theenumiv{\@arabic\c@enumiv}}%
		\sloppy
		\clubpenalty4000
		\@clubpenalty\clubpenalty
		\widowpenalty4000%
		\sfcode`\.\@m}
	{\def\@noitemerr
		{\@latex@warning{Empty `thebibliography' environment}}%
	\endlist}

	\renewenvironment{itemize}%  
	{%
	\begin{list}{\parbox{1zw}{$\bullet$}}% 見出し記号／直後の空白を調節
	{%
		\setlength{\topsep}{0zh}
		\setlength{\itemindent}{0zw}
		\setlength{\leftmargin}{1zw}%  左のインデント
		\setlength{\rightmargin}{0zw}% 右のインデント
		\setlength{\labelsep}{0.3zw}%    黒丸と説明文の間
		\setlength{\labelwidth}{3zw}%  ラベルの幅
		\setlength{\itemsep}{0em}%     項目ごとの改行幅
		\setlength{\parsep}{0em}%      段落での改行幅
		\setlength{\listparindent}{0zw}% 段落での一字下り
	}
	}{%
	\end{list}%
	}
Annual
	$tmp =~ s/^\t//;
	$tmp =~ s/\n\t(\t){0,1}/\n$1/g;
	&print_($tmp);
}

#************************************************************************
#************************************************************************
# %perl matoato.pl -h file.txt の引数に対する処理．入出力ファイルの設定 (end)
#************************************************************************
#************************************************************************



#************************************************************************
#************************************************************************
#beginning of ayato tex2txt.pl
#************************************************************************
#************************************************************************
#see 未, bug


# latex を みやすいテキストに変換
#####################################################
#	変更点
#####################################################
# 未対応の処理
#	●\max, \min, \lim, \sin → max, min, lim, sin と \ を削除する(必要？)
#	●行列の入れ子のときの処理が990109eでは, \\までの全体を"..."で囲む → 入れ子のarrayのみ "..." で囲む

#
#-----------------------------------------------------------
#$VER=	'tex2txt.pl 0.10α, 000131';
#	●変数名が {xa} と{}で囲まれる　→ xa にする。, 000131a
#		ただし \hogehoge{aaa} や "{aaa}"はそのまま
#
#$VER=	'tex2txt.pl 0.09α, 000129';
#	●{\int _{0}^t}が{∫0^t}となってしまう。→{∫_0^t}とする, 000129a
#	● \cdot が変換されない → ・に変換, 000129b
#	●行列のバグ	→ 000129c
#	\begin{eqnarray}
#	                \left[ \begin{array}{c}
#	        {A_{v}} \\
#	        {B_{v}}
#	                \end{array} \right]
#	        = {{M_{P}}}^{-1} \ {P_{v}}
#	                \label{eqn:P_v=M_P[A_v;B_v]}
#	\end{eqnarray}
#		↓
#         ／    ＼= {MP}^{-1} \ {Pv}             （eqn:P_v=M_P[A_v;B_v]）
#         ＼{Bv}／
#	●\multicolomn が μ"lticolumn になる → \mu[a-zA-Z]はμにしない, 000129d
#	●表で\begin{tabular}{@{}cc@{}}のとき, fatal error → とりあえず @{} を無視する,000129e
#	●表の \label{aaa} が変換されない. -> （aaa）に変換する, 000129f
#	●表の入れ子のとき変になる → 表の入れ子は"\begin..＆..\end{tabular}"のようにそのままにする,000129g
#	\begin{table*}[bht]%[htb]
#		\centering
#		\caption{$A(s)$ and $B(s)$}
#		\label{tbl:resultAB}	% labelはcaptionの後にしないと章番号と同じになる!
#		\begin{tabular}{|c||r|r|}
#			\hline
#			\begin{tabular}{@{}cc@{}}	$n_b$, & $n_a$ \end{tabular} & \multicolumn{1}{c|}{$B(s)$} & \multicolumn{1}{c|}{$A(s)$} \\
#			\hline
#			\hline
#			\begin{tabular}{@{}cc@{}}	3, & 4 \end{tabular} & $0.140s^3 + 2.159s^2 + 3.020s + 1.000$ & $0.119s^4 + 1.058s^3 + 3.030s^2 + 1.520s + 1.000$ \\
#			\hline
#		\end{tabular}
#	\end{table*}
#
#$VER=	'tex2txt.pl 0.08α, 000128';
#	●積分の\intが ∈ t になる。→∫にする, 000128a
#
#$VER=	'tex2txt.pl 0.07α, 990110';
#	●行列の以下のバグ, 990110a
#		\begin{eqnarray}
#		\left[{\begin{array}{ccc}    a&b \\c&d \end{array}}\right]
#		\left[{\begin{array}{c}  x\\ y \end{array}}\right] \nonumber
#		\end{eqnarray}
#			が
#		         ／a , b＼y\end{array}
#		         ＼c , d／
#			とおかしくなる

#	●行列の以下のバグ, 990110b
#		 ／-1         ,    , 0             ＼  ／1     ＼
#		 | -ap1       , .・, ：             |  | a1     |
#		 | -ap2       , .・, -1             |  |  ：    |
#		 |            ,    , -ap1           |  | a_{na} |
#		 |  ：        , .・, ：             |  | 1      |
#		 ＼-a_{p N-2} , … , -a_{p N-2-nb} ／  | b1     |
#                                              |  ：    |
#                                              ＼b_{nb}／
#			となるべきなのに
#		 ／-1 ,          , 0＼                          ／1     ＼
#		 | -ap1 , .・      , ：  |                      | a1     |
#		 | -ap2 , .・      , -1      |                  |  ：    |
#		 |      ,        , -ap1        |                | a_{na} |
#		 |  ：  , .・      , ：            |            | 1      |
#		 ＼-a_{p N-2} , … , -a_{p N-2-nb}          ／  | b1     |
#                                                       |  ：    |
#                                                       ＼b_{nb}／
#			となる

#	●行列の以下のバグ, 990110c
#		\begin{eqnarray}
#		    C = \left[{\begin{array}{c}
#		{a}_{p1}-{b}_{p1}\\
#		{a}_{p N}-{b}_{p N}\end{array}}\right]
#		\end{eqnarray}
#			が
#        C = ／_{p1} -bp1      ＼        （）
#            ＼a_{p N} -b_{p N}／
#			のように a_{p1} が _{p1} となる

#	●行列の以下のバグ, 990110d
#		\begin{eqnarray}
#		\left[{\begin{array}{c}{A}_{v}\\{B}_{v}\end{array}}\right] = {{M}_{P}}^{-1}\ {P}_{v}
#		    \label{eqn:P_v=M_P[A_v;B_v]}
#		\end{eqnarray}
#		が
#         ／Av \｛B}_v＼= {MP}^{-1} \ Pv                 （eqn:Pv =MP [Av ;Bv] ）
#		となる

#	●題名：，作成：も dollar 処理をする, 990110e
#	●eqn の \label{eqn:def:[M_B;M_B2]} が （eqn:def:[MB ;MB2 ]） となり _ が無視される。, 990110f
#	●{M}_{B}{P}_{v} が M_"BP"_v となる, 990110g
#
#$VER=	'tex2txt.pl 0.06α, 990109';
#	●990108aではunknownの入れ子もunknownとして処理したが，入れ子のlist,tbl,eqnはtxt変換する, 990109a(重要)
#	●１行の行列のとき／a,b,c＼となるがtxt2texでエラーになるので (a \ b \ c) とする, 990109b
#	●list-tbl-eqnarrayの入れ子のとき、"\begin{eqnarray}" が出力されない, 990109c
#	●...\end{array}}\right]&=&\left[{\begin{array}...のように\end,&,\beginの並びの行のとき行列の処理が入れ子と勘違いして変, 990109d
#	●行列の入れ子のときの処理が未対応→\\までの全体を"..."で囲む, 990109e
#	●\begin{unknown} abc \end{unknown} のとき\begin{unknown} \end{unknown} abc の並びになる, 990109f
#
#$VER=	'tex2txt.pl 0.05α, 990108';
#	●\begin{unknown}のとき入れ子の\begin{eqnarray}と\end{unknown}が消える, 990108a
#
#$VER=	'tex2txt.pl 0.04α, 990107';
#	●... \\の次の行が{a}のとき connect で ... \\{a} となり、\{が｛に変換される → 行末が\のとき' 'をつける, 990107a
#	●$xxx$ のとき "xxx" となるが → $"xxx"$とすべき, 990107b
#	●行列の & & が削除される→行列のとき削除しない, 990107c
#	●行列のバグ：3行以上で1列目より2列目の文字数の方が大きいとき , で揃わない, 990107d
#	●行列のとき \vdots→：, \ddots→.・に変換する, 990107e
#	●\numberinvol{13} が " νmberinvol{13}" となるが "\numberinvol{13}" とする, 990107f
#	●eqnarrayの\rightarrowがarrowとなり→にならない, 990107g
#	●0.0のとき . で改行しない, 990107h
#	●．が２つ以上あると２つ目以降が無視される．, 990107i
#	●\authorbiography → \author biography となるのを防ぐ, 990107j
#	●行列+行列のとき & の揃えがずれる, 990107k
#
#$VER=	'tex2txt.pl 0.03α, 990105';
#	●eqnarrayで\labelも\nonumberもないとき\nonumberとしてtxt変換するがLaTeXでは式番号がつく
#		→ 空の式ラベル（）をつける... \\のみ対応していたが\end{eqnarray}でも対応, 990105a
#	●下のとき, a = ("b1")/() {c1} （）となるがa = ("b1")/("c1") （）が正しい, 990105b
#		\begin{eqnarray}
#			a = \frac{{b}{1}}
#					{{c}{1}}
#		\end{eqnarray}
#	●[kg f/cm$^{2}$] が "[kg f"""/"""cm"^2"]" となるが "[kg f/cm"^2"]" が正しい, 990105c
#	●eqnarrayのあと段落の字下げ(jisage)が変(行末に。があるとうまくいく), 990105d
#		\begin{eqnarray}
#		    \beta &=& 0.01   \label{eqn:9.5} \\
#		\end{eqnarray}
#		字下げなし
#
#		字下げあり。
#	●\input{tmp/file.tex}とdirectry(unix)も対応, 990105e
#	● \lefteqn{...}のとき\lefteqnを削除, 990105f
#	●\input	file.tex の間に tab も許す, 990105g
#
#$VER=	'tex2txt.pl 0.02α, 990104';
#	● ||a||∞ の書き方を窶紡窶磨№ﾉ変更, 990104a
#	● _, ^, →,(,),{,},',窶髦,｜,→の前後の space を削除,追加, 990104b
#	●, の後ろの'\ 'を削除, 990104c
#	● N_{n}X_{n} が Nn --> "N
#	● 行列のカッコ閉じ＼ y  | となるのを＼ y ／にする, 990104e
#	●$H_NORMALのとき
#		sensitivity
#		function,
#		が "sensitivityfunction,"と改行があるのにスペースが削除される

#		 →　改行のときかつ[a-z]のときスペース挿入, 990104f
#未	● (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g
#	●\sectionの直後に\subsectionがあると節：と変換されない, 990104h
#未	●冗長な中カッコ{,} の削除, まだ不十分,990104i
#未	●YD+XN → "YD" + "XN"　とする, 不十分990104j
#	●eqnarrayで\labelも\nonumberもないとき\nonumberとしてtxt変換するがLaTeXでは式番号がつく
#		→ 空の式ラベル（）をつける, 990104k
#	●=,:に加えて>,<,≧,≦,≡,≠の前後の & を削除．, 990104l
#	●≡はunixで表示されないので≡を使う。, 990104m
#	● {} を削除, 990104n
#	● / → "/", 990104o
#	●eqnarrayの\t,' 'の繰り返しを' 'に置換する（改行して\tを使っていると広すぎる）, 990104p
#
#$VER=	'tex2txt.pl 0.01α, 990103';
#   ●図の書き方追加→図：キャプション（ラベル,file=ファイル名） ... file = ファイル名.eps, 990103a
#					→ epsboxも対応, 990103b
#	●章番号をつける... 1章：, 990103c
#	●\begin{equation} ... \end{equation}対応：, 990103d
#
#tex2txt 0.00, 981005 α版 作成開始 - 990101 α版作成終了

#---------------------------------
#	レベル０の関数

#---------------------------------
#	&verbatim;			# \begin{verbatim}のとき、そのまま出力する

#	&getLATEX_MODE;		# 今の行が図、式、表、章と普通の文章のどれか調べる

#---------------------------------
#	レベル１の関数

#---------------------------------
#	&eqn_tex2txt;				# 式を変換
#	&fig;				# 図を変換
#	&tbl_tex2txt;				# テーブルを変換
#	&list;				# 箇条書きを変換
#	&bibitem;			# 参考文献を変換
#	&theorem;			# 定理を変換
#	&beginning;			# 題名：、作成者：、章：、節：、節節：などを変換
#	&normal;			# 普通の文章を変換
#---------------------------------
#	レベル２の関数

#---------------------------------
#	&setCommand1gyou;	# \abc{a}の次の行が{aaa}のとき１行にまとめて$_=\abs{a}{aaa}とする

#	&ignor;				# const を "const" に（txtの無変換）（%も"%"にする）
#	&dollar_tex2txt;			# $x=y$ を x=y に
#	&ref;				# \ref{abc} を（abc）に
#	&LaTeXmoji_tex2txt;			# \theta を θ に


sub	tex2txt{	#ayato

	if( $H_eibun==-1 ){	&check_eibun(1);}	# 英語文書チェックと日本語コード取得とする000524c, 000524d
	else{				&check_eibun(0);}	# 日本語コード取得だけする

	if(0){	# 入出力ファイル名をここに書く場合

		open(IN,"<tex2txt.tex");
		open(OUT,">tex2txt.txt");
	}elsif(0){	# 入出力ファイル名をコマンドで指定する場合

		open(IN,"<".$ARGV[0]);
		open(OUT,">".$ARGV[1]);
	}else{
		if($H_PERL_VER==1){
			open(IN,"<".$H_INPUT_FILE);		# in the case of jperl5
			open(OUT,">".$H_OUTPUT_FILE);	# in the case of jperl5
		}elsif($H_PERL_VER==2){
			open(IN,"<".encode('cp932',$H_INPUT_FILE)); # 読み込みモード $H_INPUT_FILE=$ARGV[1]
			open(OUT,">".encode('cp932',$H_OUTPUT_FILE)); # 書き込みモード $H_OUTPUT_FILE=$filename.$kakutyousi
		}
	}

	#	ヘッダファイル（defineなど）
	&HeaderFile_tex2txt;

	#----- 初期設定 ----
	&init;


	$H_OUT='/***** Created by '.$VER.' ******/'."\n";	&print_OUT;
	if($H_eibun){	$H_OUT='#define	英文：'."\n";	&print_OUT;}	#000524c

	#while(<IN>){
	#	&level0;
	#}
	while(<IN>){
		# if($H_PERL_VER==1){	&to_euc;}	# EUCに変換000723a,000723d
		# elsif($H_PERL_VER==2){	from_to($_, "cp932", "utf8");}	#perl580
		#-----  \input abc.tex → 3階層のみ対応 ---- ここから

		if( /^[^\%]*\\input/ && s/[ 	]*\\input[ 	\{]*([0-9a-zA-Z\.\_\-\+\/]+)[ 	\}]*(.*)// ){	# 990105e,990105g
			$l0_input_filename3 = $1;
			$l0_input_after3 = $2;
			if( $l0_input_filename3 =~ /\.sty/ ){
				$H_OUT = "\\input ".$l0_input_filename3."\n";	&print_OUT;	#000606c
			}elsif( !(open(IN3,"<".$H_INPUT_FILE_DIRECTORY.$l0_input_filename3)) ){	#000519a
				$H_OUT="\\input ".$l0_input_filename3." \/\* ← tex2txt warning(".$.."): 読み込みに失敗したので変換してません！\*\/\n";&print_OUT;	&print_($H_OUT);
			}
			if( $_ ne "\n" ){
				$H_OUT="\/\*tex2txt bug \\input a \*\/".$_;&print_OUT;	# 990105g
			}
			while(<IN3>){
				&to_euc;	# EUCに変換000723a
				#-----  \input abc.tex → 2階層のみ対応 ---- ここから

				if( /^[^\%]*\\input/ && s/[ 	]*\\input[ 	\{]*([0-9a-zA-Z\.\_\-\+\/]+)[ 	\}]*(.*)// ){	# 990105e,990105g
					$l0_input_filename2 = $1;
					$l0_input_after2 = $2;
					if( $l0_input_filename2 =~ /\.sty/ ){	$H_OUT = "\\input ".$l0_input_filename2."\n";	&print_OUT;}	#000606c
					elsif( !(open(IN2,"<".$H_INPUT_FILE_DIRECTORY.$l0_input_filename2)) ){
						$H_OUT="\\input ".$l0_input_filename2." \/\* ← tex2txt warning(".$.."): 読み込みに失敗したので変換してません！\*\/\n";&print_OUT;	&print_($H_OUT);
					}
					if( $_ ne "\n" ){	$H_OUT="\/\*tex2txt bug \\input b \*\/".$_;&print_OUT;}	# 990105g
					while(<IN2>){
						&to_euc;	# EUCに変換000723a
						#-----  \input abc.tex → 1階層のみ対応 ---- ここから

						if( /^[^\%]*\\input/ && s/[ 	]*\\input[ 	\{]*([0-9a-zA-Z\.\_\-\+\/]+)[ 	\}]*(.*)// ){	# 990105e,990105g
							$l0_input_filename1 = $1;
							$l0_input_after1 = $2;
							if( $l0_input_filename1 =~ /\.sty/ ){	$H_OUT = "\\input ".$l0_input_filename1."\n";	&print_OUT;}	#000606c
							elsif( !(open(IN1,"<".$H_INPUT_FILE_DIRECTORY.$l0_input_filename1)) ){
							if( $_ ne "\n" ){	$H_OUT="\/\*tex2txt bug \\input c \*\/".$_;&print_OUT;}	# 990105g
								$H_OUT="\\input ".$l0_input_filename1." \/\* ← tex2txt warning(".$.."): 読み込みに失敗したので変換してません！\*\/\n";&print_OUT;	&print_($H_OUT);
							}
							while(<IN1>){
								&to_euc;	# EUCに変換000723a
								&level0;
							}
							if( length($l0_input_after1)>0 ){	$_=$l0_input_after1."\n";}
							else{								next;}
							close(IN1);
						}
						&level0;
						#-----  \input abc.tex → 1階層のみ対応 ---- ここまで
					}
					if( length($l0_input_after2)>0 ){	$_=$l0_input_after2."\n";}
					else{								next;}
					close(IN2);
				}
				&level0;
				#-----  \input abc.tex → 2階層のみ対応 ---- ここまで
			}
			if( length($l0_input_after3)>0 ){	$_=$l0_input_after3."\n";}
			else{								next;}
			close(IN3);
		}
		#-----  \input abc.tex → 3階層のみ対応 ---- ここまで
		&level0;
	}
	$_="\n";	# &set_begin_or_end_1gyou で貯めておいた行を吐き出す
	while(length($_)>0){	&level0;	$_='';}	# next対策


	if(length($_connect_kakko_1gyou)>0){	$H_OUT="tex2txt fatal error\(".$.."\)\:\$_connect_kakko_1gyou \"".$_connect_kakko_1gyou."\"\n";&print_OUT;&print_($H_OUT);}	#debug
	close(IN);	close(OUT);
}	# end of main of ayato tex2txt.pl


#---------------------------------
#	レベル０の関数
sub	check_eibun{	#000524c
	my	($n_eng, $n_ja, $n_euc, $n_sjis, $n_jis, $n_utf8, $tmp, $f, $tmp1);

	$f = $_[0];
	if($H_PERL_VER==1){
		open(IN_TMP,"<".$H_INPUT_FILE);				# in the case of jperl5
	}elsif($H_PERL_VER==2){
		eval 'open(IN_TMP, "<",$H_INPUT_FILE);';	# in the case of perl580 evalはいらない？
		# binmode IN_TMP, ":encoding(cp932)";
	}
 	$n_eng=1;	$n_ja=1;
	$n_euc=0;	$n_sjis=0;	$n_jis=0;	$n_utf8=0;
	while(<IN_TMP>){
		# $tmp = &jcode::getcode($_);	#日本語コードを取得000723a
		# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';	$tmp = &jcode::getcode(\$_);	eval 'I18N::Japanese;';}	#日本語コードを取得000723a,000723f,000723h
		if($H_PERL_VER==2){	$tmp='sjis';}
		if( $tmp eq 'euc'){		$n_euc++;}
		elsif( $tmp eq 'sjis'){	$n_sjis++;}
		elsif( $tmp eq 'utf8'){	$n_utf8++;}
		elsif( $tmp eq 'jis'){	$n_jis++;}

		if( $f==1 ){
			$tmp=$_;
			# $_ = Jcode->new($_)->h2z->euc;	# EUCに変換000723a
			# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';	$tmp1=&jcode::getcode(\$tmp);	&jcode::convert(\$tmp,'euc',$tmp1, "z");	eval 'I18N::Japanese;';}# EUCに変換000723f,000723h
			# elsif($H_PERL_VER==2){	from_to($tmp, "cp932", "utf8");}
			$_=$tmp;
			s/\%.*//; # %から始まる文章(コメント部分)を削除
			$n_eng += s/[a-z][\.\?\,]//g;	#000801w マッチ部を削除し、カウントする
			# $n_ja  += s/[あ-んア-ン]//g;
			while(s/[a-zA-Z0-9 	　\{\}\[\]\\\.\,\/\_\$\!\"\#\%\&\'\(\)\-\=\^\~\@\`\:\;\+\/\?\.\,]+//){;} # 半角文字、全角スペース削除
			$n_ja  += (length($_)-1)*0.1;
		}
		if($.==500){	last;} # $.はどこで定義？==>行数ぽい
	}
	if( $f==1 ){
		if( $n_ja/$n_eng < 0.1 ){	$H_eibun = 1;	$H_ignor = '';} # 英語部が日本語部より10倍より多い場合、英文判定 なぜ１０倍かは要検証
		else{						$H_eibun = 0;	$H_ignor = '"';} # 英語部が日本語部より10倍より少ない場合、和文判定
	}
	# print $n_ja."	".$n_eng."	".$H_eibun."\n";#'
	close(IN_TMP);

  if( $n_euc+$n_sjis+$n_jis+$n_utf8>0 ){	#020323a
	if( $n_euc >= $n_sjis ){		#日本語コードを取得000723a
		if( $n_euc >= $n_jis ){
			if( $n_euc >= $n_utf8 ){		$H_JCODE = 'euc';}
			else{						$H_JCODE = 'utf8';}
		}else{
			if( $n_jis > $n_utf8 ){		$H_JCODE = 'jis';}
			else{						$H_JCODE = 'utf8';}
		}
	}elsif( $n_euc < $n_sjis ){
		if( $n_sjis > $n_jis ){
			if( $n_sjis > $n_utf8 ){	$H_JCODE = 'sjis';}
			else{						$H_JCODE = 'utf8';}
		}else{
			if( $n_jis > $n_utf8 ){		$H_JCODE = 'jis';}
			else{						$H_JCODE = 'utf8';}
		}
	}
  }
	# print $n_euc.$n_sjis.$n_jis.$n_utf8.$H_JCODE."\n";
}

sub	level0{
	# ----- 処理内容(level0)-----
	chop; # 最後改行いれないと、\end{document}が文章として出力されてしまう 200624
	if( $f_verbatim>0 ){			# verbatim環境の中のとき
		&find_end_verbatim;				# \end{verbatim}を探す
	}
	if( $f_verbatim==0 ){			# verbatim環境の外のとき
		&find_begin_verbatim;			# \begin{verbatim}を探す
		# if( /[\.\\]$/ ){	$_=$_.' ';}	# 990107a
		if( /\.$/ ){	$_=$_.' ';}		# 990107a, 990110d
		s/\\\\([^ 	])/\\\\ $1/g;		# 990110d
		s/\\\\$/\\\\ /;					# 990110d
		&connect_verb_1gyou;			# \verb#ptn1\n ptn2# を１行に結合する

		&connect_kakko_1gyou;			# {a\n bc}, [abc\n ]を１行にする

		if( $H_MODE	== 1 ){	# txtへ変換
			&LaTeX2LaTeX;				# 例えば \[ ... \] を \begin{eqnarray} ... \end{eqnarray} に変換する

		}
		&set_begin_or_end_1gyou;		# \begin{abc}と\end{abc}を１行にする → level1の関数をコール

	}
	if(length($_)>0){	$H_OUT="tex2txt fatal error\(".$.."\)\: in level0 \"".$_."\"\n";&print_OUT;&print_($H_OUT);}	#debug
}

	#-----------------------------
	#	{a\n bc}, [abc\n ]を１行にする
	#
	#	input	: $_
	#	output: $_
sub	initconnect_kakko_1gyou{
	$i0_connect_kakko_1gyou = 0;
	$j0_connect_kakko_1gyou = 0;
	$k0_connect_kakko_1gyou = 0;
	$_connect_kakko_1gyou = '';
}

sub	get_percent{
	$_percent = '';
	while( s/(.*[^\\])(\%.*)/$1/ || s/^()(\%.*)// ){	# \% はコメントでない
	# while( s/(.*)(\%.*)/$1/ ){
		$_percent = $2.$_percent;
	}
}

sub	print_percent{
	if(		$H_PERCENT==0 ){
		if( length($_percent)>0 ){
			if( length($_)==0 ){	next;}
			return;
		}
	}elsif( $H_PERCENT==1 ){
		if(    $_percent =~ /^\% txt2tex / ){	next;}
		elsif( $_percent =~ /^\%[ 	　]*$/ ){	next;}
	}elsif( $H_PERCENT==2 ){
	}else{
		$H_OUT = '設定ミスです。$H_PERCENT=('.$H_PERCENT.')が定義されておりません'."\n";    &print_OUT;
	}
	if( length($_percent)>0 ){
		if($H_MODE==0){
			$H_OUT = $_percent."\n";	&print_OUT;
		}elsif($H_MODE==1){
			$H_OUT = $H_ignor.$_percent.$H_ignor."\n";	&print_OUT;
		}
		if( length($_)==0 ){
			next;
		}
	}
}

	#-----------------------------
	#	\abc{...}[...], $...$ を１行に結合する -> $...$だけ結合(大幅削除)000801s
sub	connect_kakko_1gyou{
	$l0_tmp1 = $_;

	$_=" ".$_." ";	# とりあえずスペースをくっつけて $ などをカウント。

	# $...$ が偶数かチェック
	$k0_connect_kakko_1gyou += s/[^\\]\$//g;
	while($k0_connect_kakko_1gyou>1){	$k0_connect_kakko_1gyou-=2;}

	$_ = $l0_tmp1;
	if( $i0_connect_kakko_1gyou!=0 || $j0_connect_kakko_1gyou!=0 || $k0_connect_kakko_1gyou!=0 ){
		$_connect_kakko_1gyou .= $_;	$_='';
		next;
	}else{
		$_ = $_connect_kakko_1gyou.$_;
		$_connect_kakko_1gyou = '';
	}
}

	#-----------------------------
	#	\begin{abc}と\end{abc}を１行にする
	#
	#	input	: $_
	#	output	: $_
sub	initset_begin_or_end_1gyou{
	$f_set_begin_or_end_1gyou = 0;
	@_set_begin_or_end_1gyou = '';
	$n_set_begin_or_end_1gyou = 0;
	$_connect_begin_or_end_1gyou = '';
}

sub	set_begin_or_end_1gyou{
	# $_= '# \begin{a}と\end{a}を１行にする # \begin{b}と # \begin{c}と\end{d}を１%行%に%する\end{e}を１行にする';
		# devide
		# $_='PTN1 \begin PTN2' のとき 'PTN1'と'\begin PTN2'のように複数行に分ける

	while( s/(.*)[ 	]*($H_HENKAN_COMMAND)([^a-zA-Z0-9\_].*)/$1/ ){	# 990107j
		# while( s/(.*)[ 	]*($H_HENKAN_COMMAND)(.*)/$1/ ){
		# \end{aaa}bbb を \end{aaa} と bbb に分ける, begin
		$l0_tmp = $_;	$l0_tmp1 = $2.$3;	$_ = $2.$3;
		$l0_tmp =~ s/^[ 	]+$//;	#000625q →空白行のみスペースを削除000707y
		# print $_."XXX\n";
		# if( /^(\\end\{[a-zA-Z0-9\\]+\})[ 	]*(.*)[ 	]*/ ){
		if( /^($H_HENKAN_COMMAND\{[a-zA-Z0-9\\]+\})[ 	]*(.*)[ 	]*/ ){
			if( length($2)>0 ){
				$_set_begin_or_end_1gyou[$n1_set_begin_or_end_1gyou] = $2;
				$n1_set_begin_or_end_1gyou++;
				$l0_tmp1 = $1;
			}
		}
		$_ = $l0_tmp;
		# \end{aaa}bbb を \end{aaa} と bbb に分ける, end
		
		$_set_begin_or_end_1gyou[$n1_set_begin_or_end_1gyou] = $l0_tmp1;
		$n1_set_begin_or_end_1gyou++;
	}
	if( $n1_set_begin_or_end_1gyou==0 || length($_)>0 ){	# 空行でないとき、または複数行に分けていないとき
		$_set_begin_or_end_1gyou[$n1_set_begin_or_end_1gyou] = $_;	$_='';
		$n1_set_begin_or_end_1gyou++;
	}
	while( $n1_set_begin_or_end_1gyou>0 ){
		$n1_set_begin_or_end_1gyou--;
		$_ = $_set_begin_or_end_1gyou[$n1_set_begin_or_end_1gyou];

		# connect
		# $_='\begin', '[PTN1]', '{PTN2}' のとき '\begin[PTN1]{PTN2}'のように１行に結合する

		#	・カッコを２つ結合する

		#$H_OUT=$f_set_begin_or_end_1gyou."-------------------------".$_."\n";&print_OUT;
		if( $f_set_begin_or_end_1gyou > 0 ){
			if( s/^[ 	]*([\{|\[|])[ 	]*(.*)[ 	]*([\}|\]|])[ 	]*// ){
				$f_set_begin_or_end_1gyou--;
				if( $f_set_begin_or_end_1gyou==0 ){
					$_ = $_connect_begin_or_end_1gyou.$&.$_;
					$_connect_begin_or_end_1gyou = '';
				}elsif( /^[ 	]*([\{|\[|])[ 	]*(.*)[ 	]*([\}|\]|])[ 	]*/ ){
					$_ = $_connect_begin_or_end_1gyou.$&.$_;
					$_connect_begin_or_end_1gyou = '';
					$f_set_begin_or_end_1gyou = 0;
				}else{
					if( length($_)==0 ){
						$_connect_begin_or_end_1gyou .= $&.$_;	$_='';
						next;
					}else{
						$l0_tmp = $_;
						$_ = $_connect_begin_or_end_1gyou.$&;
						$_connect_begin_or_end_1gyou = '';
						$f_set_begin_or_end_1gyou = 0;
						for($il0=0;$il0<1;$il0++){	# &level1内のnext対策
							&level1;	# 次のレベルの処理
						}
						$_ = $l0_tmp;
						if( length($_)==0 ){	# これでいいのかわからん？ bug?
							# next;
						}
						# if( $f_verbatim>0 ){
						# 	$H_OUT = $_."XXXX\n";	&print_OUT;	next;
						# }
					}
				}
			}else{
				$l0_tmp = $_;
				$_ = $_connect_begin_or_end_1gyou;
				$_connect_begin_or_end_1gyou = '';
				$f_set_begin_or_end_1gyou = 0;
				for($il0=0;$il0<1;$il0++){	# &level1内のnext対策 ==> nextはfor,while,foreach等のループ文を抜ける。&level1（&getLaTeX_MODE）にはループが存在しないため、nextはこのfor文に対して働く
					&level1;	# 次のレベルの処理
				}
				$_ = $l0_tmp;
				if( length($_)==0 ){	# これでいいのかわからん？ bug?
					# next;
				}
				if( $f_verbatim>0 ){
					$H_OUT = $_."\n";	&print_OUT;	$_='';	next;
				}
				$n1_set_begin_or_end_1gyou++;	redo;
				# $H_OUT=$f_set_begin_or_end_1gyou."++++".$_."\n";&print_OUT;#
			}
		# }elsif( s/[ 	]*($H_HENKAN_COMMAND)[ 	]*([^a-zA-Z0-9\_])[ 	]*/$2/ || s/[ 	]*($H_HENKAN_COMMAND)[ 	]*// ){	# 990107j
		}elsif( s/[ 	]*($H_HENKAN_COMMAND)[ 	]*// ){
			$_tmp = $1;
			if( s/^([\{|\[])[ 	]*// ){	# 990107j
				$_tmp .= $1;		# $_tmp='\begin{'
				while(length($_)>0){
					if( /^\}/ ){
						last;
					}
					s/^.//;
					$_tmp .= $&;
				}					# $_tmp='\begin{abc}'
				if( s/^[ 	]*([\{|\[])[ 	]*// ){	# \begin{abc}[abc]	のとき
					$_ = $_tmp.$&.$_;					# なにもしない
				}else{								# \begin{abc}		のとき
					$f_set_begin_or_end_1gyou = 1;
					$_connect_begin_or_end_1gyou = $_tmp.$_;	$_='';
					next;								# next する
				}
			}else{
				if( length($_)==0 ){				# \begin			のとき
					$f_set_begin_or_end_1gyou = 2;
					$_connect_begin_or_end_1gyou = $_tmp.$_;	$_='';
					next;								# next する
				}else{								# \date abc			のとき
					$_ = $_tmp.$_;						# なにもしない
				}
			}
		}
		# 次のレベルの処理
		&level1;	# $_='' を無視していい？ bug?
	}

	@_set_begin_or_end_1gyou = '';
	$n1_set_begin_or_end_1gyou = 0;
}

	#-----------------------------
	#	\begin{verbatim}を探す
	#	LaTeXの\verbatim環境の仕様：
	#	abc\begin{verbatim}def	... abcのあとで改行されてdefを出力
	#	abc\end{verbatim}def	... abcのあとで改行されてdefを出力
	#	eqnarray環境内では使えない
	#	abc\begin{verbatim}def\end{verbatim}ghi ... abc\n def\n ghi となる（１行に書いてもOK）
	#	input	: $_, $f_begin_verbatim>0
	#	output	: print OUT, $f_verbatim
sub	init_begin_verbatim{
	$f_begin_verbatim = 0;
}

sub	find_begin_verbatim{
	my	($f,$tmp,$tmp1);
	# percent
	&get_percent;

	if( $f_begin_verbatim == 2 ){		# 以前の行に\begin{verbatimがあったとき
		if( length($_)==0 ){
			&print_percent;
		}elsif( s/^[ 	]*\}// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 1;
		}else{
			$_ = $_verbatim.$_;
			$f_begin_verbatim = 0;
		}
	}elsif( $f_begin_verbatim == 3 ){	# 以前の行に\begin{ があったとき
		if( length($_)==0 ){
			&print_percent;
		}elsif( s/^[ 	]*verbatim[ 	]*\}// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 1;
		}elsif( s/^[ 	]*verbatim[ 	]*$// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 2;
			&print_percent;
			next;
		}else{
			$_ = $_verbatim.$_;
			$f_begin_verbatim = 0;
		}
	}elsif( $f_begin_verbatim == 4 ){	# 以前の行に\begin があったとき
		if( length($_)==0 ){
			&print_percent;
		}elsif( s/^[ 	]\{[ 	]*verbatim[ 	]*\}// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 1;
		}elsif( s/^[ 	]\{[ 	]*verbatim[ 	]*$// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 2;
			&print_percent;
			next;
		}elsif( s/^[ 	]\{[ 	]*$// ){
			$_verbatim .= $&;
			$f_begin_verbatim = 3;
			&print_percent;
			next;
		}else{
			$_ = $_verbatim.$_;
			$f_begin_verbatim = 0;
		}
	}



	$f = 1;	# 以前の行に\beginなどがないとき、\verbがあるかチェック(verbatimは有効?)000623c	
	if( s/\\verb([^a-zA-Z0-9\_])(.*)// && $f_begin_verbatim == 0 ){
		$_ = $_."\\verb".$1;	$tmp = $2;	$tmp=~s/[^$1]*//;	$tmp1=$&;	$_=$_.$tmp1.$tmp;
		if( $tmp1=~/\\begin/ ){
			$f = 0;
			$_ = $_.$_percent;	# 分離した %... をくっつけて元に戻す
		}
	}#end of 000623c

	if( $f && $f_begin_verbatim == 0 ){		# 以前の行に\beginなどがないとき
		$_verbatim='';
		while( s/\\begin[ 	]*\{[ 	]*verbatim[ 	]*\}.*// ){ # \begin{verbatim} を探す
			$_verbatim .= $&;
		}
		if( length($_verbatim)>0 ){
			$f_begin_verbatim = 1;
		}elsif( s/\\begin[ 	]*\{[ 	]*verbatim[ 	]*$// ){ # \begin{verbatim を探す
			$_verbatim = $&;
			$f_begin_verbatim = 2;
			&print_percent;
			# next;
		}elsif( s/\\begin[ 	]*\{[ 	]*$// ){ # \begin{ を探す
			$_verbatim = $&;
			$f_begin_verbatim = 3;
			&print_percent;
			# next;
		}elsif( s/\\begin[ 	]*$// ){ # \begin を探す
			$_verbatim = $&;
			$f_begin_verbatim = 4;
			&print_percent;
			# next;
		}else{ # \begin がない
			$_ = $_.$_percent;	# 分離した %... をくっつけて元に戻す
		}
	}


	if( $f_begin_verbatim == 1 ){					# \begin{verbatim} があったとき
		$f_verbatim = 4;
		$l0_percent = $_percent;
		if( length($_connect_begin_or_end_1gyou)>0 ){	# 貯めておいた行を処理して吐き出す
			$l0_tmp = $_;
			$_ = $_connect_begin_or_end_1gyou;
			$_connect_begin_or_end_1gyou = '';
			$f_set_begin_or_end_1gyou = 0;
			for($il0=0;$il0<1;$il0++){	# &level1内のnext対策

				&level1;	# 次のレベルの処理
			}
			$_ = $l0_tmp;
		}
		if( length($_)>0 && length($l0_percent)==0 ){	# 現在行の先頭が % の行は、処理しない \begin{verbatim}の前にスペースやタブが挿入されてると、length($_)>0を満たす
			for($il0=0;$il0<1;$il0++){	# &level1内のnext対策

				&level1;	# 次のレベルの処理
			}
			# &normal($block_normal);	$block_normal = '';	#000606f
		}
		&normal($block_normal);	$block_normal = '';	#000606f,000801j
		$_ = $_verbatim.$l0_percent;					# \begin{verbatim}を書く
		$_verbatim = '';
		$f_begin_verbatim = 0;
		s/^[ 	]*\\begin[ 	]*\{[ 	]*verbatim[ 	]*\}//;
		$H_OUT = '\begin{verbatim}';	&print_OUT;
		&find_end_verbatim;								# 現在行の&find_end_verbatimをする

		if( $f_verbatim>0 ){
			next;
		}
	}
}

	#-----------------------------
	#	\end{verbatim}を探す
	#	input	: $_, $f_verbatim>0
	#	output	: print OUT, $f_verbatim
	#	sub		: &find_end_verbatim_sub1, &find_end_verbatim_sub2
	#
	#	説明：
	#		$_ = 'PTN0'
	#		$_ = 'PTN1 \end PTN2 \end PTN3'のとき
	#		\endがあるとき
	#		PTN1, PTN2 のとき
	#		{verbatim} があれば	f=0, ... &find_end_verbatim_sub1
	#		なければ			f=4
	# 		PTN0, PTN3 のとき 
	#		{		   があれば	f=2, ... &find_end_verbatim_sub2
	#		なければ			f=4
	#		{verbatim  があれば	f=1,
	#		なければ			f=4
	#		{verbatim} があれば	f=0,
	#		なければ			f=4
	#
	#	$f_verbatimの説明：
	#		f=4	なにもなし
	#		f=3	\end			がある
	#		f=2	\end{			がある
	#		f=1	\end{verbatim	がある
	#		f=0	\end{verbatim}	がある
sub	init_verbatim_tex2txt{
	$f_verbatim = 0;
	$_old_verbatim = '';	# １つ前の行
	$f_verbatimOld = 5;		# $f_verbatimの１つ過去値:\end などが１つ前の行にあったが 現在行に{verbatim}がなかったときセット→print_OUT
	$f_print_old_verbatim = 0;	# すでに１つ前の行をprintしたときセット
}

sub	find_end_verbatim{
	my	($j);
	# find \end{verbatim}
	$tmp = $_;
	$k = 0;	$_tmp = '';
	while( s/(.*)(\\end)(.*)/$1/ ){	# count the number of PATTERN
		$_tmp[$k] = $2.$3;
		$k++;
	}
	if( $f_verbatim==4 ){
		if( length($_)>0 ){
			$_tmp0 = $_."\n";
		}
	}
	# if($k>0){for($i=$k-1;$i>=0;$i-- ){ print $k.'$_tmp'.$i.$_tmp[$i]."\n";}}#
	if( $k==0 ){
		&find_end_verbatim_sub1;
	}else{
		&find_end_verbatim_sub2;
		if( $f_verbatim==4 ){					# if $f_verbatim=4
			for( $i=$k-1;$i>0;$i-- ){
				$_ = $_tmp[$i];
				s/^\\end//;
				if( s/^[ 	]*\{[ 	]*verbatim[ 	]*\}[ 	]*// ){
					$f_verbatim = 0;
					last;	#000606f
				}else{
					$_ = $&.$_;
					&print_old_verbatim;
					$f_verbatim = 4;
				}
				s/\\end[ 	]*\{[ 	]*verbatim[	 ]*\}[ 	]*//;
				$H_OUT = $_;	&print_OUT;	$_='';
			}
			if( $f_verbatim==4 ){
				$_ = $_tmp[0];
				s/^\\end//;
				$f_verbatim = 3;
				&find_end_verbatim_sub1;
			}else{
				for( $j=$i-1;$j>=0;$j-- ){	$_ = $_.$_tmp[$j];}	#000606f
			}
		}
	}

		# print OUT
	if( $f_verbatim==0 ){
		$H_OUT = $_tmp0.'\end{verbatim}'."\n";	&print_OUT;
		$_old_verbatim = '';
		$f_verbatimOld = 5;
		$f_print_old_verbatim = 0;
		# f=0 no shori
	}else{
		if( $f_verbatim==4 ){
			$_ = $tmp;
			$H_OUT = $_."\n";	&print_OUT;	$_='';
			$_tmp0 = '';
		}
		$_old_verbatim = $tmp;
		$f_verbatimOld = $f_verbatim;
		$f_print_old_verbatim = 0;
	}
	if( length($_)==0 ){	next;}#000801j
}

	#-----------------------------
	#	\end などが１つ前の行にあったが 現在行に{verbatim}がなかったときprint_OUT
sub	print_old_verbatim{
	if( $f_print_old_verbatim==0 ){
		if( $f_verbatimOld <= $f_verbatim ){	# うまくいくみたいだが、バグ無しか不明？
			# $H_OUT=$f_verbatim.$tmp."XXX\n";&print_OUT;
			# $H_OUT=$f_verbatimOld.$_old_verbatim."YYY\n";&print_OUT;
			$H_OUT = $_old_verbatim."\n";	&print_OUT;
		}
	}else{
		$f_print_old_verbatim = 1;
	}
}

sub	find_end_verbatim_sub1{
	if( $f_verbatim==3 ){
		if( length($_)>0 ){
			if( s/^[ 	]*\{// ){
				$f_verbatim = 2;
			}else{
				&print_old_verbatim;
				$f_verbatim = 4;
			}
		}
	}
	if( $f_verbatim==2 ){
		if( length($_)>0 ){
			if( s/^[ 	]*verbatim// ){
				$f_verbatim = 1;
			}else{
				&print_old_verbatim;
				$f_verbatim = 4;
			}
		}
	}
	if( $f_verbatim==1 ){
		if( length($_)>0 ){
			if( s/^[ 	]*\}// ){
				$f_verbatim = 0;
			}else{
				&print_old_verbatim;
				$f_verbatim = 4;
			}
		}
	}
}

sub	find_end_verbatim_sub2{
	if( $f_verbatim==3 ){
		if( s/^[ 	]\{[ 	]*verbatim[ 	]\}[ 	]*// ){
			$f_verbatim = 0;
		}else{
			&print_old_verbatim;
			$f_verbatim = 4;
		}
	}elsif( $f_verbatim==2 ){
		if( s/^[ 	]*verbatim[ 	]\}[ 	]*// ){
			$f_verbatim = 0;
		}else{
			&print_old_verbatim;
			$f_verbatim = 4;
		}
	}elsif( $f_verbatim==1 ){
		if( s/^[ 	]\}[ 	]*// ){
			$f_verbatim = 0;
		}else{
			&print_old_verbatim;
			$f_verbatim = 4;
		}
	}
}

	#-----------------------------
	#	\verb"ab \n c"を\verb"ab c"にする
	#
	#	LaTeXの\verbコマンドの仕様：
	#		\verb@abc
	#		def@		... 改行がスペースになる. \verb@abc def@ と等価
	#		eqnarray環境内で使える
	#
	#	input	: $_, $f_begin_verb>0
	#	output	: $_, $f_verb
	#	説明： % を無視した処理
	#		既に \verb があったとき($f_verb=2)、始まりの # を探す
	#			始まりの # があれば $f_verb=1
	#			始まりの # がなければ next
	#		既に \verb# があったとき($f_verb=1)、終りの # を探す
	#			終りの # があれば $f_verb=0
	#			終りの # がなければ next
	#		現在行に \verb があるとき
	#			始まりの # があるとき
	#			終りの # があるとき、変数初期化して $_ を出力
	#			終りの # がないとき、$f_verb=1としてnext
	#			始まりの # がないとき、$f_verb=2としてnext
	#		現在行に \verb がないとき、変数初期化して $_ を出力
	#	bug: % に未対応
sub	initconnect_verb_1gyou{
	$f_verb = 0;
	$_connect_verb_1gyou = '';
	$ptn_connect_verb_1gyou = '';
}

sub	connect_verb_1gyou{
	if( $f_verb==2 ){	# 既に \verb があったとき($f_verb=2)、始まりの # を探す
		if( s/^.// ){		# 始まりの # があれば $f_verb=1
			$ptn_connect_verb_1gyou = $&;
			$_connect_verb_1gyou .= $&;
			$f_verb = 1;
		}else{				# 始まりの # がなければ next
			next;
		}
	}

	if( $f_verb==1 ){	# 既に \verb# があったとき($f_verb=1)、終りの # を探す
		while(length($_)>0){			# 終りの # があれば $f_verb=0
			s/^.//;
			$_connect_verb_1gyou .= $&;
			if( $& eq $ptn_connect_verb_1gyou ){
				$f_verb = 0;
				last;
			}
		}
		if( $f_verb==1 ){	# 終りの # がなければ next
			$_connect_verb_1gyou .= ' ';
			next;
		}
	}


	if( /\\verb/ ){						# 現在行に \verb があるとき
		# percent
		&get_percent_with_verb;
		&print_percent;
		if( /\\verb/ ){						# 現在行に \verb があるとき
			if( s/^.*\\verb(.)// ){				# 始まりの # があるとき
				# $ptn_connect_verb_1gyou = $1;
				$ptn_connect_verb_1gyou = "\\".$1;#030827a
				$_connect_verb_1gyou = $&;
				if( /$ptn_connect_verb_1gyou/ ){	# 終りの # があるとき、変数初期化して $_ を出力
					$_ = $_connect_verb_1gyou.$_;
					$_connect_verb_1gyou = '';
				}else{								# 終りの # がないとき、$f_verb=1としてnext
					$_connect_verb_1gyou .= $_.' ';
					$f_verb = 1;
					next;
				}
			}else{								# 始まりの # がないとき、$f_verb=2としてnext
				$_connect_verb_1gyou = $_;
				$f_verb = 2;
				next;
			}
		}else{								# 現在行に \verb がないとき、変数初期化して $_ を出力
			$_ = $_connect_verb_1gyou.$_;
			$_connect_verb_1gyou = '';
			$ptn_connect_verb_1gyou = '';
		}
	}else{								# 現在行に \verb がないとき、変数初期化して $_ を出力
		# percent
		&get_percent;
		&print_percent;

		$_ = $_connect_verb_1gyou.$_;
		$_connect_verb_1gyou = '';
		$ptn_connect_verb_1gyou = '';
	}
}

	#-----------------------------
	#	\verbを含む場合の get_percent に相当する処理
	#	$_ を PTN0 (\verb# PTN1 #) PTN2 (\verb# PTN3 #) PTN4に分ける
	#
	#	PTN0,2,4,... の中の % がコメントとして有効
	#
	#	input	: $_
	#	output: $_, print %PTN
sub	get_percent_with_verb{
	# $H_OUT=$_."AAAA\n";&print_OUT;
	$ptn = '';	$f = 0;	$_bef = '';
	$_percent = '';
	while(length($_)>0){
		s/^.//;	$char=$&;
		# print $f;
		# $_   = PTN0 \verb# PTN1 # PTN2
		# $f   = 0000 123456 6666 0 0000
		# $ptn =           # #### #     
		if( $f==0 && length($ptn)==0 ){			# % がコメントとして有効

			if( $char eq '%' ){
				$_percent = '%'.$_;					# get_percentに相当する処理
				last;
			}
		}

		if( $f==6 && length($ptn)!=0 ){			# 終わりの # を探す
			if( $char eq $ptn ){
				$ptn = '';
				$f = 0;
			}
		}

		if(		$f==0 && $char eq "\\"){	$f = 1;	# \verb# 以降 $f=6
		}elsif(	$f==1 && $char eq "v" ){	$f = 2;
		}elsif(	$f==2 && $char eq "e" ){	$f = 3;
		}elsif(	$f==3 && $char eq "r" ){	$f = 4;
		}elsif(	$f==4 && $char eq "b" ){	$f = 5;
		}elsif(	$f==5				  ){	$f = 6;
			$ptn = $char;								# $ptn = #
		}elsif( $f!=6				  ){	$f = 0;
		}

		$_bef .= $char;
	}
	$_ = $_bef;
	# $H_OUT="\n".$_percent."PPPP\n";&print_OUT;
	# $H_OUT=$_."ZZZZ\n";&print_OUT;
}

sub	LaTeX2LaTeX{				# 例えば \[ ... \] を \begin{eqnarray} ... \end{eqnarray} に変換する

	s/\\\[/\\begin\{eqnarray\}/g;		# \[ ... \] を \begin{eqnarray} ... \end{eqnarray} に変換
	s/\\\]/ \\nonumber \\end\{eqnarray\}/g;		# \[ ... \] を \begin{eqnarray} ... \end{eqnarray} に変換
	s/\\(le|ge)([^a-zA-Z0-9])/\\$1q$2/g;		# \le, \ge → \leq, \geq
	s/[ 	]*\\limits[ 	]*\_[ 	]*/\_/g;	# \max\limits_{a} → \max_{a} \limitsは\maxや\intで真下に条件を書けるやつ。消す必要はある？
	s/\\(begin|end)[ 	]*\{[ 	]*equation[ 	]*\}/\\$1\{eqnarray\}/g;	# \begin{equation} を \begin{eqnarray} ... \end{eqnarray} に変換, 990103d
	s/\,[ 	]*\\ /\, /g;	#●, の後ろの'\ 'を削除, 990104c
}
#---------------------------------

#---------------------------------
#	レベル１の関数
sub	level1{
	s/[ 	]+$//;	#000801o
	if($H_MODE==0){
		$H_OUT = $_."\n";&print_OUT;	$_='';	return;
	}

	s/\n$//;	# もし \n があると &ignor で無限ループに入るので削除する


	&get_newtheorem;	# 定理を変換, \newtheorem{theorem}{定理}から"定理"を取得→定理：、補題：などを選択


	while( s/  / /g ){}	# ２つ以上のスペース削除


	$_=" ".$_;
	# s/([^\\])\\([\#\~])/$1$2/g;	#000612b,000625l
	s/([^\\])\\([\#])/$1$2/g;	#000612b,000625l,000813f
	s/([^\\])\$\$/$1 /g;			#000707w
	# s/([^\\])\$([ 	]+)\$/$1$2/g;	#000707w
	s/^.//;


	s/（/\%\(/g;	s/）/\%\)/g;	#000520h,000623a
	$_= &ref($_);	# \ref{abc} abc

	&cite;			# 参考文献を変換→ \cite{abc} を "" に変換

	# \psbox[xsize=0.7\hsize]{fig_ex1.eps} → 図：（fig_ex1.eps, 0.7倍）, 000522a
	if($LATEX_MODE != $H_FIG){
		if( /^[ 	]*\\psbox[ 	]*\[[ 	]*xsize[ 	]*\=[ 	]*([0-9\.]*)[ 	]*\\hsize[ 	]*\][ 	]*\{[ 	]*([^\} 	]*)[ 	]*\}[ 	]*$/ ){
			if( $1==1 ){	$_ = "	図：（".$2."）";}
			else{			$_ = "	図：（".$2.', '.$1."倍）";}
		}
	}
	# \includegraphics[width=0.7\hsize]{fig_ex1.eps} → 図：（fig_ex1.eps, 0.7倍）,020322b
	if($LATEX_MODE != $H_FIG){
		if( /^[ 	]*\\includegraphics[ 	]*\[[ 	]*width[ 	]*\=[ 	]*([0-9\.]*)[ 	]*\\hsize[ 	]*\][ 	]*\{[ 	]*([^\} 	]*)[ 	]*\}[ 	]*$/ ){
			if( $1==1 ){	$_ = "	図：（".$2."）";}
			else{			$_ = "	図：（".$2.', '.$1."倍）";}
		}
	}


	# 今の行が図、式、表、章と普通の文章のどれか調べる

	&getLATEX_MODE;

	if( /\\def[^a-zA-Z0-9\_]/ ){	#000511b
		if( $H_ignor eq '"' ){		#000707r
			s/\"/\"\"/g;
			$H_OUT = '"'.$_."\"\n";&print_OUT;	$_='';	return;
		}else{
			$H_OUT = $_."\n";&print_OUT;	$_='';	return;
		}
	}

	&LaTeXmoji_reigai;	#000707e'

	if( $LATEX_MODE==$H_EQN ){
		if( length($_)>0 ){	$block_eqn[$i_eqn] = $_;	$i_eqn++;	$_='';	next;}
	}elsif( $LATEX_MODE==$H_FIG ){
		if( length($_)>0 ){	$block_fig[$i_fig] = $_;	$i_fig++;	$_='';	next;}
	}elsif( $LATEX_MODE==$H_TBL ){#|| $LATEX_MODE==$H_EQNinTBL){
		&put_block_tbl($_);	$_='';	next;
		# if( length($_)>0 ){	$block_tbl[$i_tbl] = $_;	$i_tbl++;	$_='';	next;}
	}elsif( $LATEX_MODE==$H_ITEM ){#|| $LATEX_MODE==$H_EQNinITEM ){
		if( length($_)>0 ){	$block_item[$i_item] = $_;	$i_item++;	$_='';	next;}
	}elsif( $LATEX_MODE==$H_BIBTEM ){
		if( length($_)>0 ){	$block_bib[$i_bib] = $_;	$i_bib++;	$_='';	next;}
	}elsif( $LATEX_MODE==$H_THEOREM ){
		# if( length($_)>0 ){	$block_theorem[$i_theorem] = $_;	$i_theorem++;	$_='';	next;}
		s/^　/"　"/;	#000520d
		&set_block_normal;		# 字下げ、"。"で区切る -> 普通の文章を変換
	}elsif( $LATEX_MODE==$H_NORMAL ){
		&set_block_normal;		# 字下げ、"。"で区切る -> 普通の文章を変換
	}elsif( $LATEX_MODE!=$H_BEGINNING ){
		$H_OUT = '/*tex2txt error('.$..'): LATEX_MODE が分かりません。変になってないかご確認ください。*/'."\n";	&print_OUT;
	}

	if(length($_)>0){	$H_OUT="tex2txt fatal error\(".$.."\)\: in level1 \"".$_."\"\n";&print_OUT;&print_($H_OUT);}	#debug
}

sub	initgetLATEX_MODE{	# 初期設定

	my ($i);

	$LATEX_MODE = $H_BEGINNING;		# 今のモード(本文、式、表、箇条書など)
	$fl1_find_section_label = 0;	# 今の行に\sectoinがあるが\labelがないとき1

	$mode_block = '';				# \begin{table} のとき $mode_block = 'table'
	@block_fig = '';	$i_fig = 0;
	@block_eqn = '';	$i_eqn = 0;
	@block_tbl = '';	$i_tbl = 0;
	@block_item = '';	$i_item = 0;
	@block_bib = '';	$i_bib = 0;
	# @block_theorem = '';	$i_theorem = 0;
	$block_normal = '';				# 文章１つ ... ex: これは、りんごです。

	&init_get_newtheorem; 

	for( $i=0;$i<20;$i++ ){	$num_section[$i] = 0;}	# 990103c
	#----- old
	$f_documentstyle_completed = 0;

	@_1gyou = '';	$n1gyou = 0;
	$_tmp = '';
}

sub	getLATEX_MODE{		#begin  \verb|..| を例外とする000611b
	my	($_1, $_2, $_new, $ptn, $f_next);
	$_new = '';
	$f_next=0;
	while( s/\\verb([^a-zA-Z])(.*)$// ){	# \verb_aaa_, \verb0aaa0など a-zA-Z以外は\verbのあとの1文字として使える

		$ptn = $1;	$_2=$2;	$_1="\\verb".$ptn;	if( $_2=~s/^[^$ptn]*[$ptn]// ){	$_1=$_1.$&;}
		# for($i=0;$i<1;$i++){	$f_next=1;	&getLATEX_MODE_hontai;	$f_next=0;}	#失敗?不要?000801y
		&getLATEX_MODE_hontai;
		$_new = $_new.$_.$_1;	$_ = $_2;
		# if( $f_next && length($_)>0 ){	$H_OUT="\n".$H_ignor.$_new.$H_ignor."\n";	&print_OUT;	$_='';	next;}
	}
	# for($i=0;$i<1;$i++){	$f_next=1;	&getLATEX_MODE_hontai;	$f_next=0;}
	&getLATEX_MODE_hontai;
	$_ = $_new.$_;
	# if( $f_next && length($_)>0 ){	$H_OUT="\n".$H_ignor.$_.$H_ignor."\n";	&print_OUT;	$_='';	next;}
}

sub	getLATEX_MODE_hontai{		# 今の行が図、式、表、章と普通の文章のどれか調べる

	my($_0, $_1, $_2, $_3);

	# txt2tex の無変換処理に使う記号 " を"に変換する begin  \verb|..| を例外とする

	s/\"/”/g; # 半角"を全角”に

	s/\\(left|right)eqn[ 	]*//g;	#	● \lefteqn{...}のとき\lefteqnを削除, 990105f"

	# \} を 全角｝ に変換する

	s/[ 	]*\\left[ 	]*\\\{/｛/g;	#000516b
	s/[ 	]*\\right[ 	]*\\\}/｝/g;
	s/\\\{/｛/g;
	s/\\\}/｝/g;

	# \left, \right を削除, 990107g, 000606a
	s/\\(left|right)[ 	]*\.//g;
	s/\\(left|right)[ 	]*([\(\)\[\]\{\}\|])/$2/g;
	s/\\(left|right)[ 	]*(\\[\{\}\|])/$2/g;

	# \documentstyle[psbox,a4j,because]{jarticle} を消す 000530i
	# psbox,a4j,because 以外のスタイルファイルが使われていると残す
	if( /^[ 	]*\\documentstyle[ 	]*(.*)[ 	]*\{[ 	]*jarticle[ 	]*\}[ 	]*(.*)[ 	]*$/ ){
		$_1 = $1;	$_2=$2;
		$_1=~s/[ 	\,\[\]]*//g;
		$_1=~s/because//g;
		$_1=~s/psbox//g;
		$_1=~s/a4j//g;
		if( length($_1)==0 ){
			if( length($_2)==0 ){
				next;
			}else{
				$_ = $_2;
			}
		}
	}
	# \documentclass[a4j,because]{jarticle} を消す 020322b
	# a4j,because 以外のスタイルファイルが使われていると残す
	if( /^[ 	]*\\documentclass[ 	]*(.*)[ 	]*\{[ 	]*jarticle[ 	]*\}[ 	]*(.*)[ 	]*$/ ){
		$_1 = $1;	$_2=$2;
		$_1=~s/[ 	\,\[\]]*//g;
		$_1=~s/because//g;
		$_1=~s/a4j//g;
		if( length($_1)==0 ){
			if( length($_2)==0 ){
				$_='';	# ナゼかこうしないとfatal errorになる 020322b
				next;
			}else{
				$_ = $_2;
			}
		}
	}
	# \usepackage[dvips]{graphicx} を消す 020322b
	if(s/^[ 	]*\\usepackage[ 	]*\[[ 	]*dvips[ 	]*\][ 	]*\{[ 	]*graphicx[ 	]*\}[ 	]*//){	next;}

	# \def\therefore{\setbox0 \hbox{$\cdot$}\raise-0.2em \copy0 \raise0.2em \copy0 \raise-0.2em \box0 ~} を消す, 000509a
	# \def\because{\setbox0\hbox{$\cdot$}\raise0.2em \copy0 \raise-0.2em \copy0 \raise0.2em \box0 ~} を消す
	$l1_tmp0 = '\def\therefore{\setbox0 \hbox{$\cdot$}\raise-0.2em \copy0 \raise0.2em \copy0 \raise-0.2em \box0 ~}';
	$l1_tmp1=$_;	$_=$l1_tmp0;	s/([\\\{\}\$\~\.\-])/\\$1/g;	$l1_tmp0=$_;	$_=$l1_tmp1;
	if( s/[ 	]*$l1_tmp0[ 	]*//g ){	if( length($_)==0 ){	next;}}
	$l1_tmp0 = '\def\because{\setbox0\hbox{$\cdot$}\raise0.2em \copy0 \raise-0.2em \copy0 \raise0.2em \box0 ~}';
	$l1_tmp1=$_;	$_=$l1_tmp0;	s/([\\\{\}\$\~\.\-])/\\$1/g;	$l1_tmp0=$_;	$_=$l1_tmp1;
	if( s/[ 	]*$l1_tmp0[ 	]*//g ){	if( length($_)==0 ){	next;}}

	if(0){	#000530i
		# \setlength{\headheight}{0mm} を消す, 000509a
		# \setlength{\textheight}{250mm} を消す
		# \setlength{\textwidth}{200mm} を消す
		if( s/[ 	]*\\setlength[ 	]*\{[ 	]*\\(headheight[ 	]*\}[ 	]*\{[ 	]*0[ 	]*mm[ 	]*\}|textheight[ 	]*\}[ 	]*\{[ 	]*250[ 	]*mm[ 	]*\}|textwidth[ 	]*\}[ 	]*\{[ 	]*200[ 	]*mm[ 	]*\})[ 	]*// ){
			if( length($_)==0 ){	next;}
		}
	}


	# \maketitle, \begin{document} を消す
	if( s/[ 	]*(\\maketitle|\\begin\{document\})[ 	]*// ){
		if( $1 eq "\\begin\{document\}" ){
			$LATEX_MODE = $H_NORMAL;
		}
		if( length($_)==0 ){	next;}
	}

	# \tableofcontents, \listoffigures などの変換
	if( s/[ 	]*(\\tableofcontents)[ 	]*// ){
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "	目次：\n";	&print_OUT;
		}else{					$H_OUT="\/\* tex2txt error981124a\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}
	if( s/[ 	]*(\\listoftables)[ 	]*// ){
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "	表目次：\n";	&print_OUT;	next;
		}else{					$H_OUT="\/\* tex2txt error981124b\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}
	if( s/[ 	]*(\\listoffigures)[ 	]*// ){
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "	図目次：\n";	&print_OUT;	next;
		}else{					$H_OUT="\/\* tex2txt error981124c\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}

	# \title{おとと}, \author{木村太郎}, \date{} の変換
	if( s/[ 	]*\\title\{(.*)\}[ 	]*// ){
		$l1_tmp0 = $1;
		$l1_tmp0 =~ s/\//\"\/\"/g;	# / → "/", 990104o, 000718c"
		$l1_tmp0 = &dollar_tex2txt($l1_tmp0);
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "題名：".$l1_tmp0."\n";	&print_OUT;	next;
		}else{					$H_OUT="\/\* tex2txt error981124d\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}
	if( s/[ 	]*\\author\{(.*)\}[ 	]*// ){
		$l1_tmp0 = $1;
		$l1_tmp0 =~ s/\//\"\/\"/g;	# / → "/", 990104o, 000718c"
		$l1_tmp0 = &dollar_tex2txt($l1_tmp0);
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "作成：".$l1_tmp0."\n";	&print_OUT;	next;
		}else{					$H_OUT="\/\* tex2txt error981124e\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}
	if( s/[ 	]*\\date\{(.*)\}[ 	]*// ){	#000603a
		$l1_tmp0 = $1;
		$l1_tmp0 =~ s/\//\"\/\"/g;	# / → "/", 990104o, 000718c"
		$l1_tmp0 = &dollar_tex2txt($l1_tmp0);
		&normal($block_normal);	$block_normal = '';	#000625o
		if( length($_)==0 ){	$H_OUT = "日付：".$l1_tmp0."\n";	&print_OUT;	next;
		}else{					$H_OUT="\/\* tex2txt error000603a\(".$.."\)\:".$1.$_."\*\/\n";&print_OUT;}	#debug
	}

	# \section{おゆ！} \label{とうーた！} の変換(章：、節：、付録：)
	&section_tex2txt;

	if(0){
		$LATEX_MODE = $H_EQN;
		$LATEX_MODE = $H_FIG;
		$LATEX_MODE = $H_TBL;
		# $LATEX_MODE = $H_EQNinTBL;
		$LATEX_MODE = $H_ITEM;
		# $LATEX_MODE = $H_EQNinITEM;
		$LATEX_MODE = $H_BIBTEM;
		$LATEX_MODE = $H_THEOREM;
		$LATEX_MODE = $H_BEGINNING;
		$LATEX_MODE = $H_NORMAL;
		# $LATEX_MODE = $H_UNKNOWN;
	}
	# 今の行が図、式、表、章と普通の文章のどれか調べる

	# if( s/[ 	]*\\begin\{([a-zA-Z]*)(\**)\}[ 	]*(\[[a-zA-Z]*\])*[ 	]*// ){	#000606f
	if( s/[ 	]*\\begin\{([a-zA-Z][a-zA-Z0-9]*)(\**)\}[ 	]*(\[[a-zA-Z][a-zA-Z0-9]*\])*[ 	]*// ){	#000801p
	# if( s/[ 	]*\\begin\{([a-z]*)(\**)\}[ 	]*(\[[a-z]*\])*[ 	]*// && ($LATEX_MODE != $H_ITEM) ){	# 箇条書の中の eqn, tbl などの入れ子対応
	  if( $LATEX_MODE == $H_ITEM && $1 ne "enumerate" ){	# 箇条書の中の eqn, tbl などの入れ子対応
		$_ = $&.$_;
	  }else{
		$_0=$&;	$_1=$1;	$_2=$2;	$_3=$3;
		$l1_tmp0="";	if( $block_normal=~s/　$// ){	$l1_tmp0="　";}	#000529c
		# if($l1_tmp0 eq "　"){$H_OUT=$_."\n";}#	$l1_tmp0="";
		&normal($block_normal);	$block_normal = $l1_tmp0;
		$mode_block = $_1;
		if(		$_1 eq "figure" ){	# 図のとき		\begin{figure}[t]
			$LATEX_MODE = $H_FIG;
			$block_fig[$i_fig] = '\begin{figure'.$_2.'}'.$_3;	$i_fig++;
			if( length($_)>0 ){	$block_fig[$i_fig] = $_;	$_='';	$i_fig++;}
			next;
		}elsif( $_1 eq "eqnarray" ){	# 式のとき
			# $LATEX_MODE = $H_EQNinTBL;
			# $LATEX_MODE = $H_EQNinITEM;
			$LATEX_MODE = $H_EQN;
			$block_eqn[$i_eqn] = '\begin{eqnarray'.$_2.'}'.$_3;	$i_eqn++;
			if( length($_)>0 ){	$block_eqn[$i_eqn] = $_;	$_='';	$i_eqn++;}
			next;
		# }elsif( $_1 eq "array" ){	# 行列のとき
			# next;
		}elsif( $_1 eq "table" || $_1 eq "tabular" ){	# 表のとき		\begin{table*}[t], \begin{tabular}
			$LATEX_MODE = $H_TBL;
			$block_tbl[$i_tbl] .= '\begin{'.$_1.$_2.'}'.$_3;	$i_tbl++;
			# if( length($_)>0 ){	$block_tbl[$i_tbl] = $_;	$_='';	$i_tbl++;}
			if( length($_)>0 ){	$block_tbl[$i_tbl] = $_;	$_='';}
			next;
		}elsif( $_1 eq "enumerate" ){# 箇条書のとき
			$LATEX_MODE = $H_ITEM;
			$block_item[$i_item] = '\begin{enumerate'.$_2.'}'.$_3;	$i_item++;
			if( length($_)>0 ){	$block_item[$i_item] = $_;	$_='';	$i_item++;}
			next;
		}elsif( $_1 eq "thebibliography" ){	# 参考文献のとき	\begin{thebibliography}{99}
			$LATEX_MODE = $H_BIBTEM;
			$block_bib[$i_bib] = '\begin{thebibliography'.$_2.'}'.$_3;	$i_bib++;
			if( length($_)>0 ){	$block_bib[$i_bib] = $_;	$_='';	$i_bib++;}
			next;
		}elsif( &find_newtheorem_begin($_1) ){	# 定理 newtheorem の \begin の処理
			# $H_OUT = $l1_newtheorem_name[$nl1_newtheorem]."：\n";	&print_OUT;
			# $LATEX_MODE = $H_NORMAL;
			$LATEX_MODE = $H_THEOREM;	#000520d
			$block_normal = "　";	# 990105d
			if( length($_)==0 ){	next;}
		}elsif( $_1 eq "abstract" ){	# 要約のとき
			&normal($block_normal);	$block_normal = '';	#000625o
			$H_OUT = "\n要約：\n";	&print_OUT;
			$block_normal = "　";	# 990105d
			$LATEX_MODE = $H_NORMAL;
			if( $LATEX_MODE==$H_NORMAL ){	$block_normal = "";}	#000529c
			if( !(/[^ 	　]/) ){	next;}	# 空白行のとき next
		}elsif( $_1 eq "array" ){	# 行列のときなにもしない
			$_ = '\begin{array'.$_2.'}'.$_3.$_;
		}elsif( $LATEX_MODE==$H_TBL ){	#000623c
			$_ = '\begin{'.$_1.$_2.'}'.$_3.$_;
			&put_block_tbl($_);	$_='';	next;
		}else{	# unknown command のとき, 990109a
			#000606d	$H_OUT = '"'.$_0.'"	/* tex2txt Warning('.$..'):未対応のコマンドです。変でないか確認してね */'."\n";	&print_OUT;
			if( $LATEX_MODE==$H_NORMAL ){	$H_OUT=$block_normal;	&print_OUT;	$block_normal = '';}#000801p
			$H_OUT = $H_ignor.$_0.$H_ignor."\n";	&print_OUT;	#000707r
			if( /^[ 	　]*$/ ){	next;}	# 空白行のとき next
		}
	  }
	#print "AAAA".$LATEX_MODE.$_1."\n";
	}elsif( !(/\\end[ 	]*\{[ 	]*array[ 	]*\}/) && s/[ 	]*\\end\{([a-zA-Z][a-zA-Z0-9]*)(\**)\}[ 	]*// ){	#行列のときなにもしない000801p
		if( $LATEX_MODE == $H_ITEM && $1 ne "enumerate" ){	# 箇条書の中の eqn, tbl などの入れ子対応, 990108a
			$_ = $&.$_;
		}else{
			if( $1 eq "abstract" ){
				&normal($block_normal);	$block_normal = '';
				$H_OUT = "\n\n";	&print_OUT;
			}elsif( &find_newtheorem_end($1) ){	# 定理 newtheorem の \end の処理
			# }elsif( $1 eq $l1_newtheorem_command[$nl1_newtheorem] ){
				# &normal($block_normal);	$block_normal = '';
				# $H_OUT = $l1_newtheorem_name[$nl1_newtheorem]."終：\n\n";	&print_OUT;
			}elsif( $LATEX_MODE == $H_EQN ){
				$block_eqn[$i_eqn] = '\end{'.$1.$2.'}';	$i_eqn++;
				&eqn_tex2txt;					# 式を変換
				@block_eqn = '';	$i_eqn = 0;
			}elsif( $LATEX_MODE == $H_TBL ){
				if( $1 eq "table" || $1 eq "tabular" ){
					$i_tbl++;	$block_tbl[$i_tbl] = '\end{'.$1.$2.'}';	$i_tbl++;
					s/^[ 	]+//g;	if(length($_)>0){	$block_tbl[$i_tbl-1] .= $_;	$_='';}	# 000129g
				}else{	#000623c
					$_ = '\end{'.$1.$2.'}'.$_;
					&put_block_tbl($_);	$_='';	next;
				}
				if( $1 eq "table" ){
					&tbl_tex2txt;					# テーブルを変換
					@block_tbl = '';	$i_tbl = 0;
				}elsif( $1 eq "tabular" ){
					# if( &find('\begin{table',$block_tbl[0]) ){	next;}	# <- bug,000129e
					if( &find('\\\begin{table',$block_tbl[0]) ){	# 000129e
						next;
					}else{
						if( $block_normal eq "　" ){	#000625p
							$H_OUT="　\n";	&print_OUT;	$block_normal='';
						}
						&tbl_tex2txt;					# テーブルを変換, \begin{table}を省略している書き方のとき
						@block_tbl = '';	$i_tbl = 0;
					}
				}else{
					next;
				}
			}elsif( $LATEX_MODE == $H_FIG ){
				$block_fig[$i_fig] = '\end{'.$1.$2.'}';	$i_fig++;
				&fig;					# 図を変換
				@block_fig = '';	$i_fig = 0;
			}elsif( $LATEX_MODE == $H_ITEM ){
				$block_item[$i_item] = '\end{'.$1.$2.'}';	$i_item++;
				&list;					# 箇条書を変換
				@block_item = '';	$i_item = 0;
			}elsif( $LATEX_MODE == $H_BIBTEM ){
				$block_bib[$i_bib] = '\end{'.$1.$2.'}';	$i_bib++;
				&bibitem;				# 参考文献を変換
				@block_bib = '';	$i_bib = 0;
			# }elsif( $LATEX_MODE == $H_THEOREM ){
			# 	$block_theorem[$i_theorem] = '\end{'.$1.$2.'}';	$i_theorem++;
			# 	&theorem;				# 定理を変換
			# 	@block_theorem = '';	$i_theorem = 0;
			}elsif( $1 eq "table" ){	# \end{tabular}のあとの\end{table}のときなにもしない, 990109a
			}elsif( $1 eq "document" ){	# \end{document}のときなにもしない, 990109a
			}else{	# unknown command のとき, 990109a
				&normal($block_normal);	$block_normal = '';	# 990109f
				# 000606d		$H_OUT = '"'.$&.'"	/* tex2txt Warning('.$..'):未対応のコマンドです。変でないか確認してね */'."\n";	&print_OUT;
				$H_OUT = $H_ignor.$&.$H_ignor."\n";	&print_OUT;	#000625c, 000707r
			}
			$LATEX_MODE = $H_NORMAL;
			# 000529c	if( $block_normal=~/　$/ ){	$l1_tmp0=$_;	s/　$//;	$block_normal=$_;	$_=$l1_tmp0;}	# 990109a
			if( !(/[^ 	　]/) ){	next;}	# 空白行のとき next
		}
	}

	if( $LATEX_MODE==$H_BEGINNING ){	# \titleなど以外の考慮していないコマンドのはじまりの処理
		if( length($_)>0 ){
			$_=&ignor_ref_reigai($_);
			$H_OUT = $H_ignor.$_.$H_ignor."\n";	&print_OUT;	$_='';	#000707r
		}else{
			$H_OUT = $_."\n";	&print_OUT;	$_='';
		}
		next;
	}

	s/\//\"\/\"/g;	# / → "/", 990104o"
}

	#-----------------------------
	#	\frac{a}{1-b} を a/(1-b) に変換する
sub	frac_tex2txt{
	# if(/frac/){print $_."-frac\n";}
	while( s/\\frac[ 	]*\{[ 	]*(.*)// ){
		$l1_tmp0 = $_;	$_ = $1;

		$l1_tmp1 = '';	$n1_tmp = 1;
		while(length($_)>0){
			s/^.//;
			if( $& eq '{' ){	$n1_tmp += 1;}
			if( $& eq '}' ){	$n1_tmp -= 1;
				if( $n1_tmp==0 ){	last;}
			}
			$l1_tmp1 .= $&;
		}
		s/^[ 	]*\{[ 	]*//;
		# $l1_tmp1 = '('.$l1_tmp1.')/(';
		$l1_tmp2 = '';	$n1_tmp = 1;
		while(length($_)>0){
			s/^.//;
			if( $& eq '{' ){	$n1_tmp += 1;}
			if( $& eq '}' ){	$n1_tmp -= 1;
				if( $n1_tmp==0 ){	last;}
			}
			$l1_tmp2 .= $&;
		}

		if( length($l1_tmp1)!=1 ){		# \phi, {a} などに未対応 → ()で囲んでしまう
			$l1_tmp1 = '('.$l1_tmp1.')';
		}else{
			$l1_tmp1 = ' '.$l1_tmp1;
		}

		if( length($l1_tmp2)!=1 ){		# \phi, {a} などに未対応 → ()で囲んでしまう
			$l1_tmp2 = '('.$l1_tmp2.')';
		}else{
			$l1_tmp2 = $l1_tmp2.' ';
		}

		$_ = $l1_tmp1.'/'.$l1_tmp2.$_;

		$_ = $l1_tmp0.$_;
		# print $_."\n";
	}
}

	#-----------------------------
	#	\section{おゆ！} \label{とうーた！} の変換(章：、節：、付録：)
sub	section_tex2txt{
	my	($i, $mylabel, $mylabelorg, $mysub, $mysection, $mytmp, $mytmp1);

	if( $fl1_find_section_label==1 ){				# 前の行に \section があったとき
		if( length($_)==0 ){	next;}
		$fl1_find_section_label = 0;
		if( s/^[ 	]*\\label\{(.*)\}[ 	]*// ){	# \labelがあるとき
			$mytmp = $1;
			$_section =~ s/^[0-9\.\-]*//;	#000519e
			$_section =~ s/[\" 	]//g;	#000606b"
			$_section =~ y/\#\%\~\\\{\}/＃％￣＼｛｝/;	#(000430a)000606b
			$mytmp1=$mytmp;	$mytmp1 =~ y/\#\%\~\\\{\}/＃％￣＼｛｝/;	#(000430a)000606b
			$mytmp1 =~ s/([^ 	])(LaTeX2e|LaTeX|TeX) ([^a-zA-Z0-9])/$1$2$3/g; 	# 000801h
			# if( $_section ne $mytmp ){print "$mytmp\n$_section\n";}
			if( $_section eq $mytmp1 ){	$H_OUT = "\n\n";}
			else{						$H_OUT = "（".&ignor_ref_reigai2($mytmp)."）\n\n";}
			&print_OUT;
			if( length($_)==0 ){	next;}
		}else{
			$H_OUT = "\n\n";	&print_OUT;
		}
	}

	if( s/^[ 	]*\\([sub]*)(section|appendix)\{(.*)\}[ 	]*\\label[ 	]*\{(.*)\}[ 	]*// ){	# \section と \label があるとき
		if( $3 eq $4 ){	$mylabelorg='';}
		else{			$mylabelorg=$4;}
		$mysub = $1;	$mysection = $2;	$mylabel = $3;
		$mylabel =~ s/\//\"\/\"/g;	# / → "/", 990104o, 000718c"
		$mylabel = &dollar_tex2txt($mylabel);
		# print $mysub." - ".$mysection." - ".$mylabel." - ".$mylabelorg."aaaaa\n";
		$LATEX_MODE = $H_NORMAL;
		&normal($block_normal);	$block_normal = '';
		$block_normal = "　";	# 990105d
		if( length($mysub)==0 ){
			if( $mysection eq "section" ){
				$mylabel = "章：".$mylabel;
				$num_section[0]++;	for($i=1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
				$_section = $num_section[0].$mylabel;
			}elsif( $mysection eq "appendix" ){
				$mylabel = "付録：".$mylabel;
				$_section = $mylabel;
			}
		}else{
			$nl1_tmp = length($mysub)/3;
			$mylabel = ("節" x $nl1_tmp)."：".$mylabel;
			$num_section[$nl1_tmp]++;	for($i=$nl1_tmp+1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
			$_section='';	for($i=0;$i<$nl1_tmp;$i++){	$_section=$_section.$num_section[$i].'.';}
			$_section=$_section.$num_section[$nl1_tmp].$mylabel;
		}
		if( length($mylabelorg)>0 ){	$H_OUT = "\n\n".$_section."（".&ignor_ref_reigai2($mylabelorg)."）\n\n";}
		else{					$H_OUT = "\n\n".$_section."\n\n";}
		&print_OUT;
		# if($H_OUT=~/\([ 	]*（/){print $H_OUT." 0\n";}
		if( length($_)==0 ){	next;}
	}elsif( s/^[ 	]*\\([sub]*)(section|appendix)[ 	]*\{(.*)\}[ 	]*// ){	# \section があるが \label がないとき
		$mysub = $1;	$mysection = $2;	$mylabel = $3;
		$mylabel =~ s/\//\"\/\"/g;	# / → "/", 990104o, 000718c"
		$mylabel = &dollar_tex2txt($mylabel);
		&normal($block_normal);	$block_normal = '';
		$block_normal = "　";	# 990105d
		$LATEX_MODE = $H_NORMAL;
		if( length($_)>0 ){										# \labelなしで本文があるとき
			if( length($mysub)==0 ){
				if( $mysection eq "section" ){
					$mylabel = "章：".$mylabel;
					$num_section[0]++;	for($i=1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
					$_section=$num_section[0].$mylabel;	$H_OUT = "\n\n".&ignor_ref_reigai2($_section)."\n\n";	&print_OUT;
				}elsif( $mysection eq "appendix" ){
					$_section="付録：".$mylabel;	$H_OUT = "\n\n".&ignor_ref_reigai2($_section)."\n\n";	&print_OUT;
				}
			}else{
				$nl1_tmp = length($mysub)/3;
				$mylabel = ("節" x $nl1_tmp)."：".$mylabel;
				$num_section[$nl1_tmp]++;	for($i=$nl1_tmp+1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
				$_section='';	for($i=0;$i<$nl1_tmp;$i++){	$_section=$_section.$num_section[$i].'.';}
				$_section=$_section.$num_section[$nl1_tmp].$mylabel;	$H_OUT="\n".&ignor_ref_reigai2($_section)."\n\n";	&print_OUT;
			}
		}else{													# 次の行以降に \label があるかもしれないとき
			$fl1_find_section_label = 1;
			if( length($mysub)==0 ){
				if( $mysection eq "section" ){
					$mylabel = "章：".$mylabel;
					$num_section[0]++;	for($i=1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
					$_section = $num_section[0].$mylabel;	$H_OUT = "\n\n".&ignor_ref_reigai2($_section);	&print_OUT;
				}elsif( $mysection eq "appendix" ){
					$_section = "付録：".$mylabel;
					$H_OUT = "\n\n".&ignor_ref_reigai2($_section);	&print_OUT;
				}
			}else{
				$nl1_tmp = length($mysub)/3;
				$mylabel = ("節" x $nl1_tmp)."：".$mylabel;
				$num_section[$nl1_tmp]++;	for($i=$nl1_tmp+1;$i<20;$i++){	$num_section[$i]=0;}	# 990103c
				$_section='';	for($i=0;$i<$nl1_tmp;$i++){	$_section=$_section.$num_section[$i].'.';}
				$_section=$_section.$num_section[$nl1_tmp].$mylabel;	$H_OUT="\n".&ignor_ref_reigai2($_section);	&print_OUT;
			}
			next;
		}
	}
}

	#-----------------------------
	#	改行 \\ で１行にする
sub	eqn_tex2txt{			# 式を変換, まだ = の位置を揃えるのが未, 行列対応
	my	($i, $_org, $_ptn, $f_array, $eqn1gyou, $i0, $tmp_eqn);

	# for($i=0;$i<$i_eqn;$i++){	$H_OUT = '"'.$block_eqn[$i]."\"\n";	&print_OUT;} return;# そのまま出力
	$_org = $_;
	# $f_array = 0;	# 0:行列でない, 1:\end{array}, 2:行列の中, 3:\begin{array}
	$f_array = 0;	# 0:行列でない, 1:\end{array}, 2:行列の中, 3:\begin{array}
	$eqn1gyou = '';

	#--- もし$block_eqn[0]="\begin{eqnarray} x=y"で x=y があるとき、これを考える

	$_=$block_eqn[0];	s/[ 	]*\\begin\{eqnarray\}[ 	]*//;	if(length($_)>0){	$i0=0;	$block_eqn[0]=$_;	}else{	$i0=1;}

	for($i=$i0;$i<$i_eqn-1;$i++){
		$_ = $block_eqn[$i];
		$_=&ignor_ref_reigai($_);
		$_=&ignor_mbox_reigai($_);
		s/：/\"：\"/g;	;#000707b"
	# print $f_array." - ".$block_eqn[0]."\n";
	# print $f_array." - ".$_."\n";
		if( /^\\begin[ 	]*\{[ 	]*array[ 	]*\}/ ){	$f_array+=1;}	# 行列の \\ は無視する

		elsif( /^\\end[ 	]*\{[ 	]*array[ 	]*\}/ ){	$f_array-=1;}
		if( $f_array==0 ){
			while( s/\\\\(.*)// ){	# 改行 \\ で１行にする

				$eqn1gyou = $eqn1gyou.$_."\\\\";	$_ = $1;
	# print $eqn1gyou." - eqn1gyou\n";
				while( $eqn1gyou=~s/(\\end\{array\})([ 	]*\\begin\{array\}.*)/$1	\\nonumber \\\\/ ){	#000527e
					$H_OUT="\/\*tex2txt error\(".$.."\)\: 1行に左カッコがない行列と右カッコがない行列が並んでます。未対応なので改行しました。"."\*\/\n";&print_OUT;	&print_($H_OUT);
					$tmp_eqn=$2;
					&eqn2($eqn1gyou);	$eqn1gyou = '';
					$eqn1gyou=$2;
				}
				&eqn2($eqn1gyou);	$eqn1gyou = '';
			}
		}else{	# 行列の部分
			s/	/ /g;	#000625r
		}
		$eqn1gyou = $eqn1gyou.$_;
	}
	# print $eqn1gyou." - eqn1gyou\n";
	&eqn2($eqn1gyou);	$eqn1gyou = '';

	if( $LATEX_MODE ==$H_EQN ){	#000511d
		$H_OUT = "\n";	&print_OUT;
	}
	$_ = $_org;
	# for($i=0;$i<$i_eqn;$i++){	$H_OUT = '"'.$block_eqn[$i]."\"\n";	&print_OUT;}	# そのまま出力
}

sub	eqn2{			# 式と行列を変換, まだ = の位置を揃えるのが未, 行列対応, 990104e
	my	($i, $_org, @y, @n, $retu, $f, $gyou, $mytmp, $max_gyou, $mytmp1, $mytmp2, $f_array_tyuukakko, $j, @max_retu, $n_array);
	my	($array_kakko, $moji_yose, $max_gyou_1);
	
	# @y:				texからtxtに処理済の行列

	# $n[$retu]:		処理中の行列の1行目の$retu列目の , までの文字数

	# $f:				1: \begin{array}があったとき
	#					2: \\があったとき
	#					3: \end{array}があったとき
	#					4: & があったとき (&→,に置き換え済)
	# $gyou:			処理中の行列の行番号

	# $max_gyou:		行列の行数

	# $max_gyou_1:		最も左の行列の行数

	# $f_array_tyuukakko	a=\left\{ 行列 \right. のとき1
	# 注意：行列の列数１００まで対応($retu)
	# @max_retu[$n_array]	: n番目の行列(n個目の\begin{array})の列数, 990110b
	  $array_kakko='';	# 行列のカッコ [, {, (, 000523a
	  $moji_yose='';	# 行列の要素の文字寄せ clr, 000523a

	#／＼
	$_org = $_;
	$_ = $_[0];

	$mytmp = '';
	while( s/\\begin[ 	]*\{[ 	]*array[ 	]*\}[ 	]*\{[a-z]*\}([^(\\\\)]*)\\end[ 	]*\{[ 	]*array[ 	]*\}(.*)// ){	# 990109b
		$mytmp = $mytmp.$_;	$_=$1;	$mytmp1=$2;
		s/\&/ \\ /g;	$mytmp = $mytmp.$_;	$_= $mytmp1;
	}
	$_ = $mytmp.$_;

	&LaTeXmoji_tex2txt;	# 990107f
	s/([^a-zA-Z0-9])\\(LaTeX2e|LaTeX|TeX)([^a-zA-Z0-9])/$1$2$3/g; 	# $...$とすべきでないもの000601b,000801g
	s/([^a-zA-Z0-9])\\(LaTeX2e|LaTeX|TeX)/$1$2 /g; 					# 000601b,000801g
	s/\\(LaTeX2e|LaTeX|TeX)/ $1 /g; 								# 000601b,000801g

	s/[ 	][ 	]+/ /g;	# eqnarrayの\tを' 'に置換する（改行して\tを使っていると広すぎる）, 990104p

	s/^[ 	]*//;
	s/[ 	]*$//;
	# if( s/[ 	\[\(\\\{]*(\\begin)[ 	]*\{[ 	]*array[ 	]*\}[ 	]*(\{[^\}]*\})*[ 	]*/$1\{array\}/ ){	# rm_tyuukakko2対策 {ll} → ll となる悪影響を削除

	$n_array = 0;	$mytmp1='';;
	# while( s/[ 	\[\(\\\{]*(\\begin)[ 	]*\{[ 	]*array[ 	]*\}[ 	]*(\{[^\}]*\})[ 	]*/$1\{array\}/ ){	# rm_tyuukakko2対策 {ll} → ll となる悪影響を削除, 990107k
	while( s/([ 	\[\(\\\{]*)\\begin[ 	]*\{[ 	]*array[ 	]*\}[ 	]*(\{[^\}]*\})[ 	]*(.*)// ){	# rm_tyuukakko2対策 {ll} → ll となる悪影響を削除, 990107k
		$mytmp1 = $mytmp1.$_."\\begin".'{array} ';	$_ = $3;	# 990110c
		$mytmp2=$2;
		if($n_array==0){	$array_kakko=$1;}	#000527e
		$mytmp2=~s/[\| 	]*//g;	$array_kakko=~s/[ 	]*//g;
		# print $2."aaaa\n";	# s///g のとき $1=$2=...='' となる

		$mytmp = $_;	$_=$mytmp2;	$max_retu[$n_array]=y/[a-zA-Z]//;	$_=$mytmp;	# get $max_retu, 990107d, 990110b
		if( length($mytmp2)-2 > length($moji_yose) ){
			# print "$moji_yose - $mytmp2".length($mytmp2).length($moji_yose)."\n";
			$mytmp=$_;
			$_=$mytmp2;	s/[\{\}]*//g;	if(/(.)$/){	$mytmp2=$1;}else{	$mytmp2='';}
			s/$mytmp2+$/$mytmp2/;	y/clr/中左右/;	$moji_yose=$_;	#000523a
			if( $moji_yose eq "左"){	$moji_yose='';}
			$_=$mytmp;
		}
		$n_array++;
	}
	$_ = $mytmp1.$_;
	# print $max_retu[0].$max_retu[1]."\n";
	$n_array = 0;

	# print $_."+++\n";
	if( s/(.*)\\label\{([^\}]*)\}(.*)/$1/ ){	# 990110f
		$mytmp = $2;	$mytmp1 = $3;
		&frac_tex2txt;
		$_ = &rm_tyuukakko($_);
		$_ = &rm_simotuki($_);
		$_ = &rm_tyuukakko2($_);
		$mytmp = $_.'\label{'.$mytmp.'}';	$_=$mytmp1;
		&frac_tex2txt;
		$_ = &rm_tyuukakko($_);
		$_ = &rm_simotuki($_);
		$_ = &rm_tyuukakko2($_);
		$_ = $mytmp.$_;
	}else{
		&frac_tex2txt;
		$_ = &rm_tyuukakko($_);
		$_ = &rm_simotuki($_);
		$_ = &rm_tyuukakko2($_);
	}
	s/\"\"//g	;#000707b"
	s/[ 	]*\\vdots[ 	]*/ ：/g;	#000517a
	s/[ 	]*\\ddots[ 	]*/ ・\./g;	#000517a
	# print $_."---\n";
	if( !(s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*/	（$1）/g || s/[ 	]*\\nonumber[ 	]*//g) ){
		if( !(s/[ 	]*\\\\[ 	]*$/	（）/) ){	# 行の最後の \\ を削除, 990104k
			s/[ 	]*$/	（）/;						# 行の最後(\end{eqnarray}) , 990105a
		}
	}else{
		s/[ 	]*\\\\[ 	]*$//;	# 行の最後の \\ を削除

	}

	#----------  \hspace{3mm}など以外の{, } を削除 000609c, begin
	$mytmp = '';
	while( s/(\\begin|\\end)(.*)$// ){	#000609c
		$mytmp1 = $1;	$mytmp2 = $2;
		$mytmp = $mytmp.&rm_tyuukakko3($_).$mytmp1;
		$_ = $mytmp2;
	}
	$_ = $mytmp.&rm_tyuukakko3($_);
	#----------  \hspace{3mm}など以外の{, } を削除, end

	# print "org2	:".$_."\n";
	# if( s/([\[\(\\\{｛  	]*)\\begin[\{ 	]*array[\} 	]*(\{[^\}]*\})*[ 	]*(.*)/ ／/ ){	# 行列のとき, 000129c:comment
		# @y = '';	$mytmp = $3;	# 000129c:comment
	if( s/([\[\(\\\{｛  	]*)\\begin[\{ 	]*array[\} 	]*(.*)/ ／/ ){	# 行列のとき, 000129c
		@y = '';	if(length($array_kakko)==0){	$array_kakko=$1;}	$mytmp = $2;	# 000129c
		$array_kakko=~s/[ 	]*//g;
		# print "$array_kakko $moji_yose \n";
		#	●=,:に加えて>,<,≧,≦,≡,≠の前後の & を削除．, 990104l, 990107c, 000623b
		s/[ 	]*\&[ 	]*([\=≡≠∝＝\>\<＜＞≧≦\:]*)[ 	]*\&[ 	]*/ $1 /;	# &=&, &:&, && の & を削除 → &を全部削除すべきかも？
		$f = 1;	# 1:\begin{array}
		$n[0] = length($_)-2;
		for($retu=1;$retu<100;$retu++){	$n[$retu] = 0;}	$retu=1;
		$gyou = 0;	$max_gyou=0;
		$y[0] = $_;	$_ = $mytmp;
		$i = 0;
		s/\,/，/g;	# 行列の","を"，"に変換
		s/[ 	]*\&[ 	]*/ \, /g;	# 行列の"&"を","に変換
					# \\ or \begin{array} or \end{array} があったとき
		s/[ 	]*\\\\[ 	]*/\\\\/g;
		# 000609c		s/[ 	\[\(\\\{]*(\\begin)[ 	]*array[ 	]*[ 	]*(\{[^\}]*\})*[ 	]*/$1\{array\}/g;
		s/[ 	\[\(\\\{]*(\\begin)[ 	]*array[ 	]*/$1\{array\}/g;	#000609c
		# print "org3	:".$_."\n";
		# s/[ 	]*(\\end)[ 	]*array[ 	]*[ 	\}\]\)]*(\\\})*[ 	\}\]\)]*/$1\{array\}/g;	# 990110a ... OK
		$mytmp=$_;	s/\\end[ 	]*array[^a-zA-Z0-9].*//;	s/.*\\begin\{array\}//;	$max_gyou_1=s/\\\\//g;	$_=$mytmp;	#000527e
		while( s/(.*[ 	]*\\end)[ 	]*array[ 	]*([\}\]\)]*)(\\\})*[ 	]*/$1\{array\}/ ){	# 990110a,000527e
			$mytmp = $2.$3;
			if(length($mytmp)==0){	$f_array_tyuukakko=1;}
			else{				$f_array_tyuukakko=0;}
		}
		# print "org3	:".$_."\n";
		# \\ or \begin{array} or \end{array} があったとき
		# s/[ 	]*\\vdots[ 	]*/ ：/g;	#990107e, 000517a
		# s/[ 	]*\\ddots[ 	]*/ ・\./g;	#990107e, 000517a
		# print "eqn2	:".$_."\n";
		while( s/(\,|\\\\|\\end\{array\}|\\begin\{array\})(.*)// ){
			# print $n_array.";n_array  ".$max_retu[$n_array]."\n";
			# $H_OUT="f=".$f.";".$1."; gyou=".$gyou."; eqn2	".$_."\n";&print_OUT;
			if(		$1 eq "\," ){	# , のとき
				if( $f==3 ){	$_=$_.$2;	next;}	# 990109d
				$retu++;
				$mytmp = ' ' x ($n[0]-length($y[$gyou]));	# 列(前)を揃えるために必要な' 'の数

				if( $f==2 ){	# 前は \\
					$y[$gyou] = $y[$gyou].$mytmp.'| '.$_;	$_ = $2;
				}else{
					$y[$gyou] = $y[$gyou].$mytmp.$_;	$_ = $2;
				}
				$i = $n[$retu]-1-length($y[$gyou]);	# 列(後)を揃えるために必要な' 'の数

				# print "i=".$i.",retu=".$retu.",length y gyou=".length($y[$gyou]).';'.$n[0]." - ".$n[1]." - ".$n[2]." - ".$n[3]." - ".$n[4]." - ".$n[5]." - ".$y[$gyou].":aaaa\n";
				if( $i>=0 ){			# この行の' 'を増やす
					$mytmp = ' ' x $i;		# 列を揃えるために必要な' 'の数

					$y[$gyou] = $y[$gyou].$mytmp.',';
					# print "   123456789012345678901234567890123456789012345678901234567890123456789\n";
					# for($j=0;$j<=$gyou;$j++){print $retu."++".$y[$j]."+++\n";}
				}else{					# 他の行の' 'を増やす
					$y[$gyou] = $y[$gyou].',';
					$mytmp = ' ' x (-$i);	# 列を揃えるために必要な' 'の数

					$mytmp1 = $_;
					for( $i=0;$i<$gyou;$i++ ){	# 990107d
						$_ = $y[$i];	$mytmp2 = '';
						for($j=$retu;$j<$max_retu[$n_array];$j++){	s/(\,[^\,]*)$//;	$mytmp2 = $1.$mytmp2;}
						$y[$i] = $_.$mytmp.$mytmp2;
					}
					for($j=$retu;$j<$max_retu[$n_array];$j++){	$n[$j] += length($mytmp);}
					# print "   123456789012345678901234567890123456789012345678901234567890123456789\n";
					# for($j=0;$j<=$gyou;$j++){print $retu."--".$y[$j]."---\n";}
					$_ = $mytmp1;
				}
				if( $gyou==0 ){	$n[$retu-1] = length($y[$gyou]);}	# 1行目($gyou=0)の , の位置までの字数

				$f = 4;	# 4: , 
			}elsif(	$1 eq "\\\\" ){	# \\ のとき
				$retu = 0;
				if( $f == 1 || $f==4 ){			# 前は \begin{array}, または ,
					if( $gyou==0 ){
						$y[$gyou] = $y[$gyou].$_."＼";	$_ = $2;
					}else{
						# $y[$gyou] = $y[$gyou].$_.' |';	$_ = $2;
						$y[$gyou] = $y[$gyou].$_;	$_ = $2;
						$i = length($y[0])-2-length($y[$gyou]);	# 列(後)を揃えるために必要な' 'の数

						if( $i>=0 ){			# この行の' 'を増やす
							$mytmp = ' ' x $i;		# 列を揃えるために必要な' 'の数

							$y[$gyou] = $y[$gyou].$mytmp.' |';
						}else{					# 他の行の' 'を増やす
							$y[$gyou] = $y[$gyou].' |';
							$mytmp = ' ' x (-$i);	# 列を揃えるために必要な' 'の数

							$mytmp1 = $_;
							for( $i=0;$i<$gyou;$i++ ){
								$_ = $y[$i];	s/(.)$//;	$mytmp2 = $1;
								$y[$i] = $_.$mytmp.$mytmp2;
							}
							$_ = $mytmp1;
						}
					}
				}elsif( $f==2 ){		# 前は \\
					$mytmp = ' ' x ($n[0]-length($y[$gyou]));	# 列(前)を揃えるために必要な' 'の数

					# print "\n".$n[0].'='.$y[0]."XX\n";
					# $y[$gyou] = $y[$gyou].$mytmp.'| '.$_.' |';	$_ = $2;
					$y[$gyou] = $y[$gyou].$mytmp.'| '.$_;	$_ = $2;
					$i = length($y[0])-2-length($y[$gyou]);	# 列(後)を揃えるために必要な' 'の数

					# print $i."iii\n";
					if( $i>=0 ){			# この行の' 'を増やす
						$mytmp = ' ' x $i;		# 列を揃えるために必要な' 'の数

						$y[$gyou] = $y[$gyou].$mytmp.' |';
					}else{					# 他の行の' 'を増やす
						$y[$gyou] = $y[$gyou].' |';
						$mytmp = ' ' x (-$i);	# 列を揃えるために必要な' 'の数

						$mytmp1 = $_;
						for( $i=0;$i<$gyou;$i++ ){
							$_ = $y[$i];	s/(.)$//;	$mytmp2 = $1;
							$y[$i] = $_.$mytmp.$mytmp2;
						}
						$_ = $mytmp1;
					}
				}elsif( $f==3 ){		# 前は \end{array}
					$_ = $2;
					last;	# 終了
				}
				$gyou++;
				$f = 2;					# 2:\\
			}elsif( $1 eq "\\end\{array\}" ){	# \end{array} のとき
				# print $1." - ".$_."	aaaa\n";
				if( $f == 1 || $f==4 ){		# 前は \begin{array}, または ,
					if( $f==1 ){
						$y[$gyou] = $y[$gyou].$_."＼";	$_ = $2;
					}else{
						$mytmp = $2;	$mytmp1 = $_;	$_ = $y[$gyou];
						s/(.*)\| /$1＼/;	#000609b
						$y[$gyou] = $_.$mytmp1;	$_ = $mytmp;
						# for($j=0;$j<=$max_gyou;$j++){print $retu."++".$y[$j]."222\n";}
						# print $gyou." - ".$y[$gyou]."	aaaa\n";
						$i = length($y[0])-2-length($y[$gyou]);	# 列(後)を揃えるために必要な' 'の数

						if( $i>=0 ){			# この行の' 'を増やす
							$mytmp = ' ' x $i;		# 列を揃えるために必要な' 'の数

							$y[$gyou] = $y[$gyou].$mytmp."／";
						}else{					# 他の行の' 'を増やす
							$y[$gyou] = $y[$gyou].'／';
							$mytmp = ' ' x (-$i);	# 列を揃えるために必要な' 'の数

							$mytmp1 = $_;
							for( $i=0;$i<$gyou;$i++ ){
								$_ = $y[$i];	s/(.)$//;	$mytmp2 = $1;
								$y[$i] = $_.$mytmp.$mytmp2;
							}
							$_ = $mytmp1;
						}
					}
					$n[0] = length($y[0])-2;
					# print "\n".$n[0].'='.$y[0]."XX\n";
				}elsif( $f==2 ){		# 前は \\
					# print "\n".$n[0].'='.$y[0]."XX\n";
					$mytmp = ' ' x ($n[0]-length($y[$gyou]));	# 列(前)を揃えるために必要な' 'の数

					# $y[$gyou] = $y[$gyou].$mytmp."＼".$_."／";	$_ = $2;
					$y[$gyou] = $y[$gyou].$mytmp."＼".$_;	$_ = $2;
					$i = length($y[0])-2-length($y[$gyou]);	# 列(後)を揃えるために必要な' 'の数

					# print $i."iii\n";
					if( $i>=0 ){			# この行の' 'を増やす
						$mytmp = ' ' x $i;		# 列を揃えるために必要な' 'の数

						$y[$gyou] = $y[$gyou].$mytmp."／";
					}else{					# 他の行の' 'を増やす
						$y[$gyou] = $y[$gyou]."／";
						$mytmp = ' ' x (-$i);	# 列を揃えるために必要な' 'の数

						$mytmp1 = $_;
						for( $i=0;$i<$gyou;$i++ ){
							$_ = $y[$i];	s/(.)$//;	$mytmp2 = $1;
							$y[$i] = $_.$mytmp.$mytmp2;
						}
						$_ = $mytmp1;
					}
				}elsif( $f==3 ){		# 前は \end{array}
					$y[0] = $y[0].$_;	$_ = $2;
					$n[0] = length($y[0]);
					$H_OUT="\/\*tex2txt error\(".$.."\)\: in eqn2a 行列の入れ子になっています。未対応です".$y[0]."\*\/\n";&print_OUT;	#debug
					$f = 99;	last;	# 990109e
				}
				$f = 3;					# 3:\end{array}
				$gyou = 0;
			}elsif( $1 eq "\\begin\{array\}" ){# \begin{array} のとき
				if( $f == 1 || $f==4 ){			# 前は \begin{array}, または ,
					$y[0] = $y[0].$_;	$_ = $2;
					$H_OUT="\/\*tex2txt error\(".$.."\)\: in eqn2b 行列の入れ子になっています。未対応です".$y[0]."\*\/\n";&print_OUT;	#debug
					$f = 99;	last;	# 990109e
					# $y[0] = $y[0]."／".$_;	$_ = $2;
					$n[0] = length($y[0])-2;
					$n_array++;	for($j=1;$j<=$max_retu[$n_array];$j++){	$n[$j] = $n[0];}
				}elsif( $f==2 ){		# 前は \\
					# $y[$gyou-1] .= '"'.$1;	$_=$2;	# 990109e
					# if( s/(\\end\{array\})(.*)// ){	$y[$gyou] .= $_.$1.'"';	$_=$2;}
					# else{	$y[$gyou] .= '"';}
					$H_OUT="\/\*tex2txt error\(".$.."\)\: in eqn2c 行列の入れ子になっています。未対応です".$y[0]."\*\/\n";&print_OUT;	#debug
					$f = 99;	last;	# 990109e
					if( $f==3 ){	$_=$_.$2;	next;}	# 990109d
				}elsif( $f==3 ){		# 前は \end{array}
					# print $_."--\n";
					$y[0] = $y[0].' '.$_." ／";	$_ = $2;
					$n[0] = length($y[0])-2;
					$n_array++;	for($j=1;$j<=$max_retu[$n_array];$j++){	$n[$j] = $n[0];}
				}
				$f = 1;					# 3:\end{array}
				$gyou = 0;	$retu=1;	# 990110b
			}
			# for($j=0;$j<=$max_gyou;$j++){print $retu."++".$y[$j]."00\n";}
			if( $gyou>$max_gyou ){	$max_gyou=$gyou;}
		}
		if( $f==99 ){	# 990109e
			$_[0] = &rm_tyuukakko3($_[0]);	#000515d
			$H_OUT='	'.$H_ignor.$_[0].$H_ignor."\n";	&print_OUT;
			$_=$_org;	return;
		}
		$y[0] = $y[0].$_;
		if( $f_array_tyuukakko==1 && $array_kakko eq "｛" ){	$array_kakko='';}	#000523a
		elsif( $f_array_tyuukakko==0 && $array_kakko eq '[' ){	$array_kakko='';}
		elsif( length($array_kakko)==0 ){						$array_kakko='N';}
		for($i=0;$i<=$max_gyou;$i++){
			$_ = $y[$i];
			if( $f_array_tyuukakko==1 ){	s/[ 	]*[\|／＼][ 	]*(（[^（）]*）)*$/$1/;}
			if( $array_kakko eq 'N' && $i<=$max_gyou_1 ){		s/(\| |／|＼)(.*)$/  $2/;}	#000527e
			# $H_OUT="$max_gyou $max_gyou_1";&print_OUT;
			s/(（[^（）]*）)$/	$1/;	# 行列の式とlabel の間に tab を入れる

			if( (length($array_kakko)>0&&$array_kakko ne 'N') || length($moji_yose)>0 ){	#000523a
				$mytmp=$array_kakko;	$mytmp=~s/N//g;#	$mytmp=~s/([\{\(])/\\$1/g;
				if( !(s/(（[^（）]*)）$/$1\, $mytmp$moji_yose）/) ){
					$mytmp=$array_kakko;	$mytmp=~s/[\\N]//g;
					$_=$_."	（欠番：\,".$mytmp.$moji_yose."）";	#000527c
				}
				# print "$_ XXX $array_kakko YYY $moji_yose ZZZ\n";
				if($array_kakko ne 'N'){	$array_kakko='';}	$moji_yose='';	#000527e
			}
			# 000609c			$_ = &rm_tyuukakko3($_);	#000515d
			# s/^(  [a-zA-Zａ-ｚＡ-Ｚ]*[0-9０-９]*[\:\;\.\,．\)\}\]）｝」。・，○●◎○◇□△▽☆★●◆■▲▼◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤﾄ・佛・ｽﾅ塲黴ﾅ槐､ﾅｹﾅｽﾅｻﾄ・崘てｾﾅｺﾋ敘ｾﾅｼﾅ汎てｹﾄ・呼估堝芝η・絶ぎﾂ黴!ﾂ､|ca≪-R￣23・，1o≫ﾂｼﾂｽEEEEIIIIDNOOOOOOUUUUceeeeiiiiuytyﾄﾄｪﾅｪﾄ椎呼・愬ｬﾄ夏敍･ﾄｵﾅ敘ｭﾉｱﾊ極ｾﾊμ痛ｬﾉｮﾉｹﾊ伊緬ｳﾉｽﾊぬ惜ｻﾉｭﾉ淤ｲ蝮ｼ笶ｶ笶ｷ笶ｸ])/ $1/;	# 981121e, 000504e, 000707t
			s/^(  [a-zA-Zａ-ｚＡ-Ｚ]*[0-9０-９]*[\:\;\.\,．\)\}\]）｝」。・，○●◎○◇□△▽☆★●◆■▲▼◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ])/ $1/;	# 981121e, 000504e, 000707t,030825a
			$H_OUT = "	".$_."\n";	&print_OUT;	#行列

		}
		# print "y0:  ".$y[0].": y0\n";
		# print "y1:  ".$y[1].": y1\n";
		# print "y2:  ".$y[2].": y2\n";
	}else{						# 行列以外の式
		#	●=,:に加えて>,<,≧,≦,≡,≠の前後の & を削除．, 990104l, 990107c, 000623b
		s/[ 	]*\&[ 	]*([\=≡≠∝＝\>\<＜＞≧≦\:]+)[ 	]*\&[ 	]*/ $1 /;	# &=&, &:&, && の & を削除 → &を全部削除すべきかも？000529a
		if( !(/[\=≡≠∝＝\>\<＜＞≧≦\:]/) ){	#000623b
			s/^([ 	]*)\&([ 	]*)\&/$1$2/;	#000529a
		}elsif( /（/ ){
			if( !(/[\=≡≠∝＝\>\<＜＞≧≦\:].*（/) ){	#000623b
				s/^([ 	]*)\&([ 	]*)\&/$1$2/;	#000529a
			}
		}
		# 000609c		$_ = &rm_tyuukakko3($_);	#000515d
		s/\([ 	]*(（[^）]*）)[ 	]*\)/$1/g;	# (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g, 000516a
		s/^(  [a-zA-Zａ-ｚＡ-Ｚ]*[0-9０-９]*[\:\;\.\,．\)\}\]）｝」。・，○●◎○◇□△▽☆★●◆■▲▼◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ])/ $1/;	# 981121e, 000504e, 000707t,030825a
		$H_OUT = "	".$_."\n";	&print_OUT;	#行列以外
		$_='';
	}

	$_ = $_org;
}

	#-----------------------------
	#	図：キャプション（ラベル,filename.eps,上下ここ頁,1.0倍） ... キャプション省略時\begin{figure}[t]なし, 000522a
sub	fig{			# 図を変換
	my	($i, $f_ps, $label, $caption, $file, $_org, $pos, $size);	# $_orgを使うとsubの変更で値が変わる→perlのバグ？←my の変数を()で囲むとOK

	$_org = $_;
	$f_ps = 0;		# psファイルを使っているとき 1
	$label = '';	# ラベルがあるとき length>0
	$caption = '';	# captionがあるとき length>0
	$file = '';		# file name があるとき length>0
	$pos = '';		# [tbhp]
	$size = '';		# [0.9\hsize]
	for($i=0;$i<$i_fig;$i++){
		$_ = $block_fig[$i];
		$_=&ignor_ref_reigai($_);
		if( /(xsize|width)[ 	]*\=[ 	]*([0-9\.]+)[ 	]*\\hsize/ ){	#030813
			$size = $2;
		}
		if( /\\begin[ 	]*\{[ 	]*figure[ 	]*\}[ 	]*\[[ 	]*([tbhp]*)[ 	]*\]/ ){
			$pos = $1;
		}
		if( /(psbox|epsfile|includegraphics)/ ){	# 990103a, 030813
			$f_ps = 1;
		}
		if( s/\\label\{[ 	]*(.*)[ 	]*\}// ){
			$label = $1;
		}
		if( s/\\caption\{[ 	]*(.*)[ 	]*\}// ){
			$caption = &dollar_tex2txt($1);
		}
		if( /.*[\{\=][ 	]*(.*)\.eps[^a-zA-Z0-9\_]/o ){	# psbox, epsbox, fileの拡張子.epsのみ対応, 990103b
			$file = $1;
		}
	}

	if( $f_ps==1 && length($label)>0 ){
		$H_OUT = "\n	図：".$caption;
		if( length($label)>0 ){
			$H_OUT .= "（".$label;
			if( $file ne $label ){
				# $H_OUT .= ', file='.$file;
				$H_OUT .= ', '.$file.'.eps';	#000511a
			}else{	#000625b
				$H_OUT .= '.eps';
			}
			if( $pos eq "tbh" ){	$pos = '';}
			$pos=~y/tbp/上下頁/;	$pos=~s/h/ここ/g;
			if( length($pos)>0 ){
				$H_OUT .= ', '.$pos;
			}
			if( length($size)>0 ){
				if( $size != 1 ){	$H_OUT .= ', '.$size."倍";}
			}
			$H_OUT .= "）";
		}
		$H_OUT .= "\n\n";	&print_OUT;
	}else{
		for($i=0;$i<$i_fig;$i++){	$H_OUT = $H_ignor.$block_fig[$i].$H_ignor."\n";	&print_OUT;}	# そのまま出力
	}

	$_ = $_org;
}

	#-----------------------------
	#	テーブルを変換
sub	tbl_tex2txt{			
	my	($i, $j, $k, $k0, $_org, $_ptn, $f, @num, $idx_num, $my_tmp, @num_yoko, @num_youso);
	my	($pos, $moji_yose, $label, $caption, $_buf, $tmp, $f_no_table);	#000522b
	#	@num_youso		: @num_yousoは j 列目の要素の長さの max数(縦罫線を揃えるために必要)
	#	@num_yoko		: @num_yokoは i 行目の横罫線 - の数

	#					ex:	_________________
	#						|       || "c"  | のとき @num_yoko= 1
	#						=================
	#						| "a    "|| "d" |					2
	#						| "b    "|| "e" |					0
	#						-----------------					1
	#	$num[$idx_num]	: @numは縦罫線|の数 ex: | a || b | のとき@num=121
	#	$f				: \begin{table}縲彌begin{tabular}まで $f=0
	#					: \begin{tabular}{|c||c|} のとき $f=1
	#					: \begin{tabular}縲彌end{table} のとき $f=2

	# for($i=0;$i<$i_tbl;$i++){	$H_OUT = '"'.$block_tbl[$i]."\"\n";	&print_OUT; print $H_OUT;}	# そのまま出力
	$_org = $_;
	&abs_norm_tex2txt;
	$pos='';		# [tbhp], 表の位置
	$moji_yose='';	# [cllr], 文字寄せ
	$label='';		# \label{...}, ラベル

	$caption='';	# \caprion{...}, キャプション

	$_buf = '';		# \begin{table}...\begin{tabular}をためる

	$f_no_table=1;	# \begin{table}でないとき1

	$H_OUT = "	表：";	&print_OUT;
	for($i=1;$i<$i_tbl-1;$i++){		# caption を書く
		$_ = $block_tbl[$i];
		if( s/[ 	]*(.*)\\caption\{([^\}]*)\}(.*)[ 	]*$/$2/ ){
			$_ptn = $1.$3;
			while( s/\}(.*)// ){	$_ptn=$_ptn.$1;}
			s/^[ 	]*//;
			s/[ 	]*$//;
			$_ = &dollar_tex2txt($_);
			$caption="表：".$_;
			$H_OUT = $_;  &print_OUT;	$_='';
			$block_tbl[$i] = $_ptn;
			last;
		}
	}
	# 000517c	$H_OUT = "\n";	&print_OUT;
	$f = 0;	$k=0;	# $k 出力する表の行数

	for($i=0;$i<$i_tbl-1;$i++){
		$_ = $block_tbl[$i];
		$_=&ignor_ref_reigai($_);
		# if(/^[ 	]*$/){	next;}	#000522b
		# s/\@\{\}//g;	# 000129e, @{}を無視する

		if( $i==0 ){
			if( s/\\begin[ 	]*\{table(\*)*\}\[([a-z]*)\][ 	]*// ){	# \begin{table}がないときに$i=1から始めるとダメ, 990109c 000522b
				$pos=$2;	$pos=~y/tbp/上下頁/;	$pos=~s/h/ここ/g;
				if( $pos eq "上下ここ" ){	$pos='';}else{	$pos=', '.$pos;}
				$f_no_table=0;
			}
		}
		if( $f==0 ){	# 000129g
			if( s/\\begin[ 	]*\{tabular\}// ){		# \begin{table}縲彌begin{tabular}まで $f=0
				$f = 1;
			}
		}
		if( $f==1 ){
			if( s/^[ 	]*\{([^\}]*)\}(.*)/$1/ ){
				$my_tmp = $2;
				s/[ 	]*//g;
				$j=0;	$idx_num=0;	$num[$idx_num]=0;	# @numは|の数 ex: | a || b | のとき@num=121
				$moji_yose=$_;
				while(length($_)>0){
					if( s/^[a-zA-Z]// ){ 
						$num[$idx_num] = $j;
						$idx_num++;
						$j = 0;
					}elsif( s/^\|// ){
						$j++;
					}else{
						$H_OUT="\/\*tex2txt fatal error\(".$.."\)\: in tbl\, \\tabular\{ccc\}の中にc,\|以外の文字があります ".$block_tbl[$i]."\*\/\n";&print_OUT;	&print_($H_OUT);	die;	#debug
					}
				}
				$num[$idx_num] = $j;
				$f = 2;
				# print @num;
				$_=$moji_yose;	s/\|//g;	if(/(.)$/){	$tmp=$1;}else{	$tmp='';}	s/$tmp+$/$tmp/;	y/clr/中左右/;	$moji_yose=$_;	#000522b
				if( $moji_yose eq "中左"){	$moji_yose='';}else{	$moji_yose=', '.$moji_yose;}
				# print "$caption, $label, $moji_yose, $pos, $_buf, $tmp\n";
				if( length($label)>0 || length($pos)>0 || length($moji_yose)>0 ){
					$H_OUT = "（".$label.$pos.$moji_yose."）\n".$_buf;	&print_OUT;
				}else{
					$H_OUT = "\n".$_buf;	&print_OUT;
				}

				$_ = $my_tmp;
			}
		}
		if( $f<2 ){					# \begin{table}縲彌begin{tabular}までの行をコメントして出力する

			s/[ 	]*\\centering[ 	]*//;	#000517c
			if( length($_)==0 ){	next;}
			if( s/[	 ]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*(.*)// ){	# 000129f
				$label = $1;	$_ptn = $2;
				if( length($_)!=0 ){	s/^([ 	]*)(.*)([ 	]*)$/	\"$2\"/;}
				if( length($_ptn)>0 ){	$_ .= '	"'.$2."\"";}
				if( $label eq $caption ){	$label='';}
			}
			if( /[^ 	]/ ){	$_bug = $_buf.'	'.$_."\n";}
			# if( /[^ 	]/ ){	$H_OUT = '	'.$_."\n";   &print_OUT;}#'
			next;
		}

		if( !(/\\verb([^a-zA-Z0-9\_])/) ){	# 横罫線(\hline)の数を数える000623c
			$j = s/\\hline//g;				#	\verbがないとき(\hlineが有効なとき)
		}else{								#	\verb!\hline!かもしれないとき
			$j = 0;	$tmp='';
			while(s/\\verb([^a-zA-Z0-9\_].*)/\\verb/){
				$my_tmp=$1;		$j+=s/\\hline//g;
				$tmp=$tmp.$_;	$_=$my_tmp;	$tmp=$tmp.&get_verb_nakami;
			}
			$j+=s/\\hline//g;
			$_=$tmp.$_;
		}
		$num_yoko[$k] = $j;
		# s/\\end\{tabular\}//;
		s/\\\\[ 	]*$//;
		s/^[ 	]*//;
		s/[ 	]*$//;
		s/[ 	]+(\&)+[ 	]+/ $1 /g;	s/[ 	]+(\&)+/ $1/g;	s/(\&)+[ 	]+/$1 /g;	#000801m
		s/	/ /g;	# tabを削除(tab=4と8で表が崩れるので)
		if( $j==0 && length($_)==0 ){	next;}	# 000129g
		&frac_tex2txt;	# \frac{a}{1-b} を a/(1-b) に変換する, 000609a
		$_ = &dollar_tex2txt($_);

		$block_tbl[$k] = " ".$_;	$k++;
	}
	#	●表の入れ子のとき変になる → 表の入れ子は"\begin..＆..\end{tabular}"のようにそのままにする,000129g
	$k-=2;	# 000129g
	# $H_OUT="$j $k  $f_no_table $i_tbl $block_tbl[$k] \n";&print_OUT;
	if(!($block_tbl[$k]=~/^[ 	]*$/)){	$k++;	$block_tbl[$k]='';}	#000522b一番下に\hlineがないとき必要
	# for( $i=0;$i<$k+2;$i++ ){$H_OUT=$i.":::".$block_tbl[$i]."\n";&print_OUT;}
	$j = 0;	$i = 0;#	$k0 = $k-$#block_tbl;
	while( $i < $k ){	# 000129g
		if( $block_tbl[$i] eq " $H_ignor\\begin\{tabular\}$H_ignor" ){
			$block_tbl[$j] = $block_tbl[$i];	$num_yoko[$j] = $num_yoko[$i];
			while(1){
				$i++;#	$k--;
				if( $i>$k ){	$j++;	last;}
				$_ = $block_tbl[$i];
				if(/^ $H_ignor\\end\{tabular\}$H_ignor/){
					$block_tbl[$j] .= $_;
					if( $_ eq " $H_ignor\\end\{tabular\}$H_ignor" ){
						$i++;	$block_tbl[$j] .= $block_tbl[$i];	$num_yoko[$j] += $num_yoko[$i];
					}
					last;
				}else{
					s/\&/ ＆/g;	$block_tbl[$j] .= $_;	#000517d
				}
			}
		}else{
			$block_tbl[$j] = $block_tbl[$i];	$num_yoko[$j] = $num_yoko[$i];
		}
		$j++;	$i++;
	}
	$num_yoko[$j] = $num_yoko[$i];
	$k = $j;#$k0;
	# for( $i=0;$i<$k+2;$i++ ){$H_OUT=$i.":::".$block_tbl[$i]."\n";&print_OUT;}

	# 縦罫線の位置を揃えるために、各要素の長さを調べる。(@num_yousoに代入)
	for( $j=0;$j<$idx_num;$j++ ){	$num_youso[$j] = 0;}	# 初期化
	for( $i=0;$i<$k;$i++ ){
		$block_tbl[$i]=~s/｜/ ｜/g;	#000517d
		$_ = $block_tbl[$i];
		for( $j=0;$j<$idx_num;$j++ ){
			$_ptn='';	if( s/\&(.*)// ){	$_ptn = $1;}
			if( $num_youso[$j] < length($_) ){	$num_youso[$j] = length($_);}
			# print "\$num_youso\[".$j."\]= ".$num_youso[$j].$_."\n";
			$_ = $_ptn;
		}
		if( /\&/ ){	$H_OUT="tex2txt error\(".$.."\)\: in tbl: \& があまった".$block_tbl[$i]."\n";}
	}
	# 縦罫線の位置を揃える。
	for( $i=0;$i<$k;$i++ ){
		$_ = $block_tbl[$i];	$block_tbl[$i]='';
		for( $j=0;$j<$idx_num;$j++ ){
			$_ptn = '';	if(s/\&(.*)//){	$_ptn = $1;}
			$my_tmp='';	$my_tmp = '|' x $num[$j];
			if( $num[$j]!=0 ){			# | と & が対応しているとき & を | に置き換える

				$block_tbl[$i] .= $my_tmp;
			}else{
				if( $j!=0 ){	$block_tbl[$i] .= '&';}	# もともと | がないとき & を残す(txt2tex.pl 0.16は未対応)
			}
			$my_tmp='';	$my_tmp = ' ' x ($num_youso[$j]-length($_));
			$block_tbl[$i] .= $_.$my_tmp;
			$_ = $_ptn;
		}
	}
	# for( $i=0;$i<$k;$i++ ){$H_OUT=$block_tbl[$i]."\n";&print_OUT;}
	# 出力する

	for( $i=0;$i<$k;$i++ ){
		$j = $num_yoko[$i];
		while($j>0){				# 横罫線(\hline)を出力
			if( $j>=2 ){
				$my_tmp = '=' x (length($block_tbl[0])+$num[$idx_num]);	# ==========
				$H_OUT = '	'.$my_tmp."\n";	&print_OUT;
				$j-=2;
			}else{
				$my_tmp = '-' x (length($block_tbl[0])+$num[$idx_num]);	# -----------
				$H_OUT = '	'.$my_tmp."\n";	&print_OUT;
				$j--;
			}
		}
		$H_OUT = "	";
		# $H_OUT .= '|' x ($num[0]);
		# $H_OUT .= " ";
		# 000606a		$block_tbl[$i]=~s/ ｜/\"\|\"/g;
		$block_tbl[$i]=~s/ ＆/\"\&\"/g;	$block_tbl[$i]=~s/\"([ 	]*)\"/ $1 /g;#000517d"
		$H_OUT .= $block_tbl[$i];#."\n";	&print_OUT;
		$tmp = '|' x $num[$idx_num];	$H_OUT .= $tmp."\n";
		&print_OUT;
	}
	$j = $num_yoko[$i];
	while($j>0){				# 横罫線(\hline)を出力
		if( $j>=2 ){
			$my_tmp = '=' x (length($block_tbl[0])+$num[$idx_num]);	# ==========
			$H_OUT = '	'.$my_tmp."\n";	&print_OUT;
			$j-=2;
		}else{
			$my_tmp = '-' x (length($block_tbl[0])+$num[$idx_num]);	# -----------
			$H_OUT = '	'.$my_tmp."\n";	&print_OUT;
			$j--;
		}
	}
	$H_OUT = "\n";	&print_OUT;	#000813e

	$_ = $_org;
	# for($i=0;$i<$i_tbl;$i++){	$H_OUT = '"'.$block_tbl[$i]."\"\n";	&print_OUT;}	# そのまま出力
}

	#-----------------------------
	#	$block_tblに代入する
	#
	#	\hline ... \hlineと ...\\ で改行する
	#
	#	&put_block_tbl($_);	$_='';	next;
	#		if( length($_)>0 ){	$block_tbl[$i_tbl] = $_;	$i_tbl++;	$_='';	next;}
sub	put_block_tbl{
	my ($_org, $my_tmp, $f, $tmp);

	if( length($_[0])==0 ){	return;}
	$_org = $_;
	$_ = $_[0];

	while( s/\\\\(.*)// ){
		$my_tmp = $1;
		$_ = $block_tbl[$i_tbl] = $block_tbl[$i_tbl].$_."\\\\";
		$f = 0;
		if( s/.*\\verb([^a-zA-Z0-9\_])// ){	#000623c
			$tmp=$1;
			if( !(/[$tmp]/) ){
			# if( !(s/$tmp//) ){
				$f = 1;		# \verb!\\! のとき
			}
		}
		if( $f==0 ){	$i_tbl++;}	# \\ があると改行
		$_ = $my_tmp;
	}
	$block_tbl[$i_tbl] = $block_tbl[$i_tbl].$_;

	$_ = $_org;
}

	#-----------------------------
	# 箇条書きを変換
sub	list{			
	my	($i, $j, $_org, $f, @_ptn, $my_tmp, $f_kaigyou, $f_ireko, $my_1gyou);
	my	($tmp1, $tmp2, $tmp3, $f_no_return, $f_no_return_old);

	# for($i=0;$i<$i_item;$i++){	$H_OUT = '"'.$block_item[$i]."\"\n";	&print_OUT;}	return;	# そのまま出力
	$_org = $_;
	for($i=1;$i<$i_item-1;$i++){
		$_ = $block_item[$i];
		if( s/[ 	]*\\renewcommand[ 	]*\{[ 	]*\\labelenumi[ 	]*\}[ 	]*\{[ 	]*(.*)[ 	]*\}[ 	]*// ){
			$block_item[$i] = $_;
			$my_tmp = $_;	$_ = $1;
			$f = 0;
			$_ptn[0] = $1;
			if( s/(.*)[ 	]*\\arabic[ 	]*\{[ 	]*enumi[ 	]*\}[ 	]*(.*)// ){
				$f = 1;
				$_ptn[0] = $1;
				$_ptn[1] = $2;
			}
			last;
		}
	}
	# $H_OUT = $_ptn[0].$f.$_ptn[1]."\n";	print $H_OUT;
	# $H_OUT = "	　";	&print_OUT;
	$j = 1;	$f_kaigyou = 0;	$f_ireko = 0;
	$my_1gyou = '';
	for($i=1;$i<$i_item-1;$i++){
		$_ = $block_item[$i];
		$_=&ignor_ref_reigai($_);
	# print $f_ireko." ".$_."aaaa\n";
		s/^[ 	]*//;
		$f_no_return=0;	#000511d

		#------------------------------------------------------------
		# \begin{abc}...\end{abc}環境の入れ子の変換
		#------------------------------------------------------------
		# 箇条書(enumerate環境)	- 表(table環境)		- 表(tabular環境)
		# 						- 式(eqnarray環境)	- 行列(array環境)
		#------------------------------------------------------------
		# $f_ireko	= 0: 入れ子なし
		#			= 1: eqnarray
		#			= 2: table
		#			= 3: tabular
		#------------------------------------------------------------
		if( s/\\begin\{([a-z]*)(\**)\}[ 	]*(.*)// ){
			$tmp1=$1;	$tmp2=$2;	$tmp3=$3;
			$my_tmp = '\begin{'.$tmp1.$tmp2.'}'.$tmp3;
			# print "\n".$f_ireko.$1."BBBBB\n";
			if( $f_ireko==0 ){
				if(		$tmp1 eq "eqnarray" ){
					#-- 今まで貯めといた文字を出力
					$_ = $my_1gyou.$_;	$my_1gyou = '';
					s/[ 	]*(\\nonumber)[ 	]*//;
					s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*$/	（$1）/;
					$_ = &dollar_tex2txt($_);
					s/^[ ]*//;	s/[ 	]*$//;
					$H_OUT = $_;	&print_OUT;	$_='';
					#-- 式を貯める

					$f_ireko = 1;
					if( $f_no_return==0 && $f_no_return_old==0 ){	#000511d
						$H_OUT = "\n";	&print_OUT;
					}
					if( $i_eqn!=0 ){	$H_OUT="\/\*tex2txt error\(".$.."\)\: in list of eqn".$_."\*\/\n";&print_OUT;}	#debug
					else{				$block_eqn[$i_eqn] = '\begin{eqnarray'.$tmp2.'}';	$i_eqn++;	#000511d
										if( length($tmp3)>0){$block_eqn[$i_eqn] = $tmp3;	$i_eqn++;}}
					# else{				$block_eqn[$i_eqn] = '\begin{eqnarray'.$tmp2.'}'.$tmp3;	$i_eqn++;}
					# else{				$block_eqn[$i_eqn] = $my_tmp;	$i_eqn++;}
				}elsif( $1 eq "table" ){
					#-- 今まで貯めといた文字を出力
					$_ = $my_1gyou.$_;	$my_1gyou = '';
					s/[ 	]*(\\nonumber)[ 	]*//;
					s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*$/	（$1）/;
					$_ = &dollar_tex2txt($_);
					s/^[ ]*//;	s/[ 	]*$//;
					$H_OUT = $_;	&print_OUT;	$_='';
					#-- 式を貯める

					$f_ireko = 2;
					$H_OUT = "\n";	&print_OUT;
					if( $i_tbl!=0 ){	$H_OUT="\/\*tex2txt error\(".$.."\)\: in list of tbl 1".$_."\*\/\n";&print_OUT;}	#debug
					# else{				$block_tbl[$i_tbl] = '\begin{table'.$2.'}'.$3;	$i_tbl++;}
					# else{				$block_tbl[$i_tbl] = $my_tmp;	$i_tbl++;}
					else{				&put_block_tbl($my_tmp);}
				}elsif( $1 eq "tabular" ){
					#-- 今まで貯めといた文字を出力
					$_ = $my_1gyou.$_;	$my_1gyou = '';
					s/[ 	]*(\\nonumber)[ 	]*//;
					s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*$/	（$1）/;
					$_ = &dollar_tex2txt($_);
					s/^[ ]*//;	s/[ 	]*$//;
					$H_OUT = $_;	&print_OUT;	$_='';
					#-- 式を貯める

					$f_ireko = 3;
					$H_OUT = "\n";	&print_OUT;
					if( $i_tbl!=0 ){	$H_OUT="\/\*tex2txt error\(".$.."\)\: in list of tbl 2".$_."\*\/\n";&print_OUT;}	#debug
					# else{				$block_tbl[$i_tbl] = '\begin{tabular'.$2.'}'.$3;	$i_tbl++;}
					# else{				$block_tbl[$i_tbl] = $my_tmp;	$i_tbl++;}
					else{				&put_block_tbl($my_tmp);}
				}else{
					$_ = $_.$&;
				}
			}else{
				$_ = $_.$&;
			}
		}elsif( s/(.*)\\end\{([a-z]*)(\**)\}// ){
			if( $f_ireko!=0 ){	$f_no_return=1;}#000511d
			if(		$2 eq "eqnarray" && $f_ireko==1 ){
				$f_ireko = 0;
				$block_eqn[$i_eqn] = '\end{'.$2.$3.'}';	$i_eqn++;
				&eqn_tex2txt;					# 式を変換
				@block_eqn = '';	$i_eqn = 0;
			}elsif(	$2 eq "table" && $f_ireko==2 ){
				$f_ireko = 0;
				$i_tbl++;	$block_tbl[$i_tbl] = '\end{'.$2.$3.'}';	$i_tbl++;
				&tbl_tex2txt;					# 式を変換
				@block_tbl = '';	$i_tbl = 0;
			}elsif(	$2 eq "tabular" && $f_ireko==3 ){
				$f_ireko = 0;
				$i_tbl++;	$block_tbl[$i_tbl] = '\end{'.$2.$3.'}';	$i_tbl++;
				&tbl_tex2txt;					# 式を変換
				@block_tbl = '';	$i_tbl = 0;
			}else{
				$_ = $&.$_;
				if( $f_ireko==0 ){
					$my_1gyou = $my_1gyou.$&;
				}
			}
		}
		if(		$f_ireko==1 ){
			if( length($_)>0 ){	$block_eqn[$i_eqn] = $_;	$i_eqn++;	$_='';}
			next;
		}elsif( $f_ireko==2 || $f_ireko==3 ){
			# if( length($_)>0 ){	$block_tbl[$i_tbl] = $_;	$i_tbl++;	$_='';}
			&put_block_tbl($_);	$_='';
			next;
		}
		#---- 入れ子の処理

		# print OUT $f_no_return.$f_no_return_old;
		while( s/[ 	]*\\item[ 	]*(.*)// ){
			$my_tmp = $1;
			$_ = $my_1gyou.$_;	$my_1gyou = '';
			s/[ 	]*(\\nonumber)[ 	]*//;
			s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*$/	（$1）/;
			$_ = &dollar_tex2txt($_);
			s/^[ ]*//;	s/[ 	]*$//;
			$H_OUT = $_;	&print_OUT;
			if( $f==1 ){	$H_OUT = "	　".$_ptn[0].$j.$_ptn[1]." ";}
			else{			$H_OUT = "	　".$_ptn[0];}
			$j++;
			if( $j>2 && $f_no_return==0 && $f_no_return_old==0 ){	$H_OUT = "\n".$H_OUT;}	#000511d
			&print_OUT;
			$_ = $my_tmp;
		}
		$f_no_return_old = $f_no_return;	#000511d
		$my_1gyou = $my_1gyou.$_;
	}
	$_ = $my_1gyou;	$my_1gyou = '';
	s/[ 	]*(\\nonumber)[ 	]*//;
	s/[ 	]*\\label\{[ 	]*(.*)[ 	]*\}[ 	]*$/	（$1）/;
	s/\([   ]*(（[^）]*）)[     ]*\)/$1/g;  # (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g, 000516a, 000520e,000801n
	$_ = &dollar_tex2txt($_);
	s/^[ ]*//;	s/[ 	]*$//;
	$H_OUT = $_;	&print_OUT;	$_='';

	$H_OUT = "\n";	&print_OUT;
	$H_OUT = "\n";	&print_OUT;	#000813e

	$_ = $_org;
	# for($i=0;$i<$i_item;$i++){	$H_OUT = '"'.$block_item[$i]."\"\n";	&print_OUT;}	# そのまま出力
}

	#-----------------------------
		#参考文献をTeXに変換
	#	ex:
	#	参考文献：
	#	apple1)文献１
	#	参4a)文献２
	#
	#	参考文献の仕様(txt2tex)：
	#		1: /^参考文献：/の下に参考文献を書く
	#		2: /^参照ラベル)文献名など/ のように参照ラベルと文献名などの間に ) を入れる
	#
	#		2a: 参照ラベルに（と）と(と)を書かない
	#		3: ) がない行まで参考文献とみなす
	#		4:箇条書きの中の式を処理できる．
	#		5:参照するときは（参照ラベル）と書くとTeXで 1) となる。
	#
	#	参考文献の仕様(tex2txt)：
	#		1: \cite{abc} を"（参：abc）"と変換
	#
	#	981219
sub	bibitem{			# 参考文献を変換
	my	($i, $_org, @_ptn, $mytmp0, $mytmp1);

	$_org = $_;
	$H_OUT = "\n参考文献：";	&print_OUT;
	# apple1)文献��
	@_ptn = '';
	for($i=2;$i<$i_bib-1;$i++){
		$_ = $block_bib[$i];
		$_=&ignor_ref_reigai($_);

		s/^[ 	]*//;
		s/[ 	]*$//;
		while( s/[ 	]*\\bibitem\{([^\}]*)\}[ 	]*(.*)// ){
			$mytmp0 = $1;	$mytmp1 = $2;
			$_ptn[1] = $_ptn[1].$_;
			$_=$mytmp0;	s/参：//;	$mytmp0=$_;	#000511c
			$H_OUT = &dollar_tex2txt($_ptn[1]);	$H_OUT = $_ptn[0].$H_OUT."\n";	&print_OUT;
			$_ptn[0] = "参：".$mytmp0.')';	$_ptn[1] = '';	#000511c
			$_ = $mytmp1;
		}
		$_ptn[1] = $_ptn[1].$_;
	}
	$H_OUT = &dollar_tex2txt($_ptn[1]);	$H_OUT = $_ptn[0].$H_OUT."\n";	&print_OUT;

	$_ = $_org;
	# for($i=0;$i<$i_bib;$i++){	$H_OUT = '"'.$block_bib[$i]."\"\n";	&print_OUT;}	# そのまま出力
}

sub	cite{			# 参考文献を変換→ \cite{abc} を "" に変換
	s/\\cite[ 	]*\{[ 	]*参：[ 	]*([^\}]*)\}/（参：$1）/g;	#000511c
	s/\\cite[ 	]*\{([^\}]*)\}/（参：$1）/g;
}

	#-----------------------------
	#
	#	定理などを変換する関数群	\labelの処理が未
	#
	#	定理、補題、証明の書き方
	#
	#	定理：ラベル
	#
	#	内容
	#	定理終：
	#
	#	参照は定理（定理：ラベル）と書くと定理1となる, 980924
	#	(定理|補題|証明)：→theorem, lemma, proof
sub	get_newtheorem{		# 定理を変換, \newtheorem{theorem}{定理}から"定理"を取得→定理：、補題：などを選択

	if( s/[ 	]*\\newtheorem[ 	]*\{([^\}]*)\}[ 	]*\{([^\}]*)\}[ 	]*// ){
		$l1_newtheorem_command[$nl1_newtheorem] = $1;	# \newtheorem{theorem}{定理} の theorem
		$l1_newtheorem_name[$nl1_newtheorem] = $2;		# \newtheorem{theorem}{定理} の 定理
		$l1_newtheorem_number[$nl1_newtheorem] = 0;		# \begin{theorem} の 順番番号 = 定理3：の 3
		$nl1_newtheorem++;								# \newtheorem{theorem}{(.*)} の 数

		if( length($_)==0 ){	next;}
	}
	# if(/\\newtheorem/){print "newtheorem:	".$l1_newtheorem[0]."	".$l1_newtheorem[1]." OOO ".$_."\n";}
}

sub	init_get_newtheorem{
	@l1_newtheorem_command = '';	# \newtheorem{theorem}{定理} の theorem
	@l1_newtheorem_name = '';		# \newtheorem{theorem}{定理} の 定理
	@l1_newtheorem_number = '';		# \begin{theorem} の 順番番号 = 定理3：の 3
	$nl1_newtheorem = 0;			# \newtheorem{theorem}{(.*)} の 数
}

sub find_newtheorem_begin{	# 定理 newtheorem の\beginの処理
	my( $f, $myptn, $i );

	$myptn = $_[0];
	$f = 0;			# $myptn の中に $l1_newtheorem_command があると1
	for($i=$nl1_newtheorem-1;$i>=0;$i--){
		if( $l1_newtheorem_command[$i] =~ $myptn ){
			$nl1_newtheorem[$i]++;	# 定理番号更新
			$f = 1;	last;
		}
	}
	if( $f==1 ){	# $myptn の中に $l1_newtheorem_command があるとき"定理3："を出力
		&normal($block_normal);	$block_normal = '';
		$H_OUT = $l1_newtheorem_name[$i].$nl1_newtheorem[$i]."：";	&print_OUT;	#000517b
	}
	return $f;
}

sub find_newtheorem_end{	# 定理 newtheorem の\endの処理
	my( $f, $myptn, $i );

	$myptn = $_[0];
	$f = 0;			# $myptn の中に $l1_newtheorem_command があると1
	for($i=$nl1_newtheorem-1;$i>=0;$i--){
		if( $l1_newtheorem_command[$i] =~ $myptn ){
			$f = 1;	last;
		}
	}
	if( $f==1 ){	# $myptn の中に $l1_newtheorem_command があるとき"定理終："を出力
		&normal($block_normal);	$block_normal = '';
		$H_OUT = $l1_newtheorem_name[$i]."終：\n\n";	&print_OUT;
	}
	return $f;
}

	#-----------------------------
	#-----------------------------
	#	普通の文章のとき、ただの改行のとき１行にまとめる
	#
	#	普通の文章のとき、改行が２つ以上あるとき行の先頭に段落寄せ　を付ける
sub	set_block_normal{	# 字下げ、"。"で区切る

	my ($mytmp);	# 990107i

	if( /^	図：（/ ){	#000522a
		&normal($block_normal);	$block_normal = '';
		$H_OUT=$_."\n";	&print_OUT;	$_='';	return;
	}
	s/^[ 	]//;
	# 000707y	s/[ 	]$//;
	if( length($_)==0 ){
		&normal($block_normal);	$block_normal = '';
		$block_normal = "　";	# 990105d
	}

	while( s/([^0-9０-９g][ 	]*[．。！？\.\?\!]+)(.*)/$1/ ){	# 0-9 以外のあとに。があると改行する, 990107h, Fig.は改行なし, 990107i
		$mytmp = $2;
		if( /\.$/ && $mytmp=~/[^ 	]/ ){	# cherry.yyy.or.jp などのとき000604a
			$block_normal = $block_normal.$_;
		}else{
			if( /^[a-zA-Z0-9]/ && $block_normal=~/[a-zA-Z0-9\,]$/ ){	$_ = ' '.$_;}	# 990104f, 000707z
			$block_normal = $block_normal.$_;
			$_ = '';
			&normal($block_normal);	$block_normal='';
		}
		$_ = $mytmp;
	}
	if( /^[a-zA-Z0-9]/ && $block_normal=~/[a-zA-Z0-9\,]$/ ){	$_ = ' '.$_;}	# 990104f, 000707z
	if( s/^[　 	]*\\label[ 	]*\{[ 	]*(定理：|補題：|証明：)([^\}]*)\}/$2/g ){	#000517b
		$mytmp=$_;	$_=$block_normal;	s/　$//;	$block_normal = $_.$mytmp;
		$H_OUT = $block_normal."\n";	&print_OUT;	$block_normal='';	#000520d
	}else{
		$block_normal .= $_;
	}
	$_ = '';
}

	#-----------------------------
	#	普通の文章を変換
sub	normal{			# 普通の文章を変換
	my	($_org, $_bef, $_aft, $tmp1, $tmp2, $tmp3);

	if( $block_normal eq "　" ){	$block_normal='';	return;}	# 990105d

	$_org = $_;
	$_ = $_[0];

	# if( s/[ 	]*\\begin\{([a-zA-Z]*)(\**)\}[ 	]*(\[[a-zA-Z]*\])*[ 	]*// ){	#000606f
	s/^[ 	]//;
	s/[ 	]$//;
	if( length($_)>0 ){
		# print "normal	:".$_."\n";
		&frac_tex2txt;	# \frac{a}{1-b} を a/(1-b) に変換する, 990105b

		s/\([   ]*(（[^）]*）)[     ]*\)/$1/g;  # (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g, 000516a, 000520e

		$_aft='';
		while( s/(.*)(（[^）]*）)// ){	#000520h
			$_bef = $1;	$tmp1=$2;	$tmp2=$_;
			# print "$_bef - $tmp1 - $tmp2 000\n";
			$tmp3=s/\$//g;	while($tmp3>=2){	$tmp3-=2;}
			if( $tmp3==0 ){
				$_aft= $tmp1.&dollar_tex2txt($tmp2).$_aft;
			}else{
				$_aft= $tmp1.&dollar_tex2txt('$'.$tmp2).$_aft;
				$_bef = $_bef.'$';
			}
			$_=$_bef;
			# print "$tmp3 $_ - $_aft 111\n";
		}
		$_= &dollar_tex2txt($_).$_aft;

		$_=&ignor_ref_reigai($_);

		$H_OUT=$_."\n";	&print_OUT;
	}
	$_ = $_org;
}
#---------------------------------

#	&setCommand1gyou;	# \abc{a}の次の行が{aaa}のとき１行にまとめて$_=\abs{a}{aaa}とする
#
#	&ignor;				# const を "const" に（txtの無変換）（%も"%"にする）
#	&dollar_tex2txt;			# $x=y$ を x=y に
#	&ref;				# \ref{abc} を（abc）に
#	&LaTeXmoji_tex2txt;			# \theta を θ に


#---------------------------------
#	レベル２の関数
	#-----------------------------
	#	$...$ の中を txt に変換する処理
	#	注意！  入力の改行 \n を必ず削除しておくこと！→無限ループ
	#	$...\begin{array}[ll]...\end{array}...$ はそのまま "..." で囲む。
sub	dollar_tex2txt{	# \verb|..| を例外とする000611b,000801y
	my	($_org, $_1, $_2, $_new, $ptn);
	$_org=$_;	$_=$_[0];

	$_new = '';
	while( s/\\verb([^a-zA-Z])(.*)$// ){	# \verb_aaa_, \verb0aaa0など a-zA-Z以外は\verbのあとの1文字として使える

		$ptn = $1;	$_2=$2;	$_1="\\verb".$ptn;	if( $_2=~s/^[^$ptn]*[$ptn]// ){	$_1=$_1.$&;}
		$_=&dollar_tex2txt_hontai($_);
		$_new = $_new.$_.$_1;	$_ = $_2;
	}
	$_=&dollar_tex2txt_hontai($_);
	$_new = $_new.$_;

	$_=$_org;
	return $_new;
}

sub	dollar_tex2txt_hontai{				# $x=y$ を x=y に
	# local	$_org, $_ptn, $out, $i;
	my	($_org, $_ptn, $out, $i, $mytmp, $mytmp2);

	$_org = $_;	$_ = $_[0];
	&LaTeXmoji_tex2txt;	# 990107f
	if( /\n/ ){	$H_OUT="\/\*tex2txt bug\(".$.."\)\: in dollar \\nが残ってます".$_."\*\/\n";&print_OUT;}	#debug

	$_=" ".$_;
	s/([^\\])\$\$/$1\\ /g;	#000801t, 000813d
	s/^ //;

	s/(\([ 	]*)\{([ 	]*[^\(\)\{\}\[\]]*[ 	]*)\}([ 	]*\))/$1$2$3/g;	# ({ a/b }) -> ( a/b ),000801u
	s/(\[[ 	]*)\{([ 	]*[^\(\)\{\}\[\]]*[ 	]*)\}([ 	]*\])/$1$2$3/g;	# [{ a/b }] -> [ a/b ],000801u
	s/(｛[ 	]*)\{([ 	]*[^\(\)\{\}\[\]]*[ 	]*)\}([ 	]*｝)/$1$2$3/g;	# ｛{ a/b }｝ -> ｛ a/b ｝,000801u
	$i = 0;	$_ptn = '';	$out = '';
	while( s/^(.*)\$// ){
		$_ptn = $_;	$_ = $1;
		if( $i==2 ){	$i = 0;}
		if( $i==1 ){
			if( $_ptn=~/\\begin/ || $_ptn=~/\\end/ ){
				$_ptn = '"$'.$_ptn.'$"';
			}else{
				$_ptn = &rm_tyuukakko($_ptn);
				$_ptn = &rm_simotuki($_ptn);
				$_ptn = &rm_tyuukakko2($_ptn);
				$_ptn =~ s/^[ 	]*//;	#000520b
				$_ptn =~ s/[ 	]*$//;	#000520b
				if( $H_eibun ){	$_ptn = '$'.$_ptn.'$';}	#000524b
			}
			$mytmp = $_;	$_ = $_ptn;
			# if( s/^\"([^\"]*)\"$/$1/ ){	# 990107b
			# 	if( $1 eq '/' ){	$_ptn = $H_ignor.$1.$H_ignor;}	#000611c
			# 	else{				$_ptn = $H_ignor.'$'.$1.'$'.$H_ignor;}
			# }
			$_ptn='';	# $a_b aa$->"aa" ab ->"$aa$" ab
			while( s/\"([^\"]*)\"(.*)$/$1/ ){	# 990107b"
				$mytmp2=$2;	#単なるバグ000813n
				if( $1 eq '/' ){	$_ptn = $_ptn.$H_ignor.$_.$H_ignor;}	#000611c
				else{				$_ptn = $_ptn.$H_ignor.'$'.$_.'$'.$H_ignor;}
				$_=$mytmp2;
			}
			$_ptn = $_ptn.$_;
			$_ = $mytmp;
		}else{
			if( $H_eibun==0 ){	$_ptn = &ignor($_ptn);}	#000524b
		}
		$i++;
		$out = $_ptn.$out;
	}
	if( length($_)>0 && /[^ 	　\n]/ ){
		$_ = &ignor($_);
	}
	$out = $_.$out;

	$out=" ".$out;
	while( $out=~s/([^\\])(\$\$|\"\")/$1/ ){}	#000813n
	$out=~s/^ //;

	$out=~s/\\(LaTeX2e|LaTeX|TeX)([^a-z])/$1$2/g; 	# $...$とすべきでないもの000601b,000801b"
	$_ = $_org;
	return $out;
}

	#-----------------------------
	#
	#	{{a}_{b}} を {a_b} のようにむだな { } を削除する
	#
	#	_{} と ^{} を削除する
	#
	#	未：\phiに未対応...今は１文字の場合だけ
	#		$caption = &rm_tyuukakko($1);
sub	rm_tyuukakko{
	my	($out, $_org);

	$_org = $_;
	$_ = $_[0];
	s/\}\{/\} \{/g;	#	●{M}_{B}{P}_{v} が M_"BP"_v となる, 990110g,frac_tex2txtから移動000625d
	s/\}([a-zA-Z0-9])/\} $1/g;		# a}b→a} b, 990104d
	s/([a-zA-Z0-9])\{/$1 \{/g;		# a{b→a {b, 990104d
	s/\{[ 	]*(.)[ 	]*\}/$1/g;		# {{a}_{b}} を {a_b} のようにむだな { } を削除する

	s/[\_\^][ 	]*\{[ 	]*\}//g;	# _{} と ^{} を削除する

	s/\{[ 	]*\}//g;	# {} を削除, 990104n
	$out = $_;
	# $out = $_[0];
	$_ = $_org;
	return $out;
}

	#-----------------------------
	#	{ab} を ab のようにむだな { } を削除する
sub	rm_tyuukakko2{
	my	($out, $_org);
	my	($_new, $_aft, $nakami, $_reigai);

	$_org = $_;
	$_ = $_[0];
	# s/\{([\\a-zA-Z]+)\}/$1/g;
	s/[ 	]*([^\_√√])[ 	]*\{([\\a-zA-Z]+)\}[ 	]*/$1 $2 /g;	# _{aaa} と √{aa} の{} は削除しない000801r

	#	● _, ^, →,(,),{,},',窶髦,｜,→の前後の space を削除,追加, 990104b
	s/([\(])[ 	]+/$1 /g;
	s/[ 	]+([\)])/ $1/g;
	s/\( (.) \)/\($1\)/g;		#000520g
	s/([\{\[])[ 	]*/$1/g;	#000520g
	s/[ 	]+([\{\[])/ $1/g;	#000520g
	s/[ 	]*([\}\]\'])/$1/g;	#000520g
	s/([\}\]\'])[ 	]+/$1 /g;	#000520g
	s/[ 	]*([\_\^→])[ 	]*/$1/g;	#窶磨bを除く000801a'

	# 未	●冗長な中カッコ{,} の削除, まだ不十分,990104i
	s/\[[ 	]*\{([^\[\]\{\}]*)\}[ 	]*\]/\[$1\]/g;
	s/\([ 	]*\{([^\[\]\{\}]*)\}[ 	]*\)/\($1\)/g;
	s/\{[ 	]*\{([^\{\}]*)\}[ 	]*\}/\{$1\}/g;
	# while(s/\{[ 	]*([a-zA-Z0-9]*)[ 	]*\}/$1/g){}	# {ab} -> ab 000131a
	# while(s/\{[ 	]*([a-zA-Z0-9]*[\/]*[a-zA-Z0-9]*)[ 	]*\}/$1/g){}	# {ab},{a/b}->ab,a/b: 000131a
 	while(s/\{[ 	]*([＾\~￣]*[a-zA-Z0-9$def_txt_hensuuAll]*[\/]*[＾\~￣]*[a-zA-Z0-9$def_txt_hensuuAll]*)[ 	]*\}/$1/g){}	# {ab},{a/b}->ab,a/b: 000131a, 000512a
	s/\{[ 	]*([＾\~￣])[ 	]+/\{$1/g;	#000512a
 	while(s/\{[ 	]*([＾\~￣ 	]*[a-zA-Z0-9$def_txt_hensuuAll]*)[ 	]*\}/$1/g){}	# {ab},{a/b}->ab,a/b: 000131a, 000512a
 	while(s/([^\^\_][ 	]*)\{[ 	]*\-[ 	]*([a-zA-Z0-9$def_txt_hensuuAll]*[\/]*[a-zA-Z0-9$def_txt_hensuuAll]*)[ 	]*\}/$1\-$2/g){}	# {-a} -> -a: x^{-a}は残す 000131a

	# { { {( Bp (s))/( Ap (s))} } } -> ( Bp (s))/( Ap (s)), 000515b
	# {s^N Kp X2 (s) { { {(U(s))/( Ap (s) A(s))} } } } -> {s^N Kp X2 (s) {(U(s))/( Ap (s) A(s))} }は未
	$_new='';
	while(s/\{.*// ){
		$_new=$_new.$_;	$_=$&;	$nakami = &get_kakko_nakami_LtoR("quiet");	$_aft=$_;
		$_=$nakami;	while( /^[ 	]*\{([ 	]*\{.*\}[ 	]*)\}[ 	]*$/ ){	$_=$1;}	$_new=$_new.$_;
		$_=$_aft;
	}
	$_=$_new.$_;

	$_ = &rm_tyuukakko3($_);	#000515c

	$out = $_;
	$_ = $_org;
	return $out;
}
	#-----------------------------
	#	_{}, ^{}以外の{}を削除(begin), 000515c
	#	入れ子{{...}} は {...}のように残る
sub	rm_tyuukakko3{
	my	($out, $_org);
	my	($_new, $_aft, $nakami, $_reigai);

	$_org = $_;
	$_ = $_[0];
	# s/\{([\\a-zA-Z]+)\}/$1/g;
	$_new='';	$_=' '.$_;
	$_reigai='';	if( s/\\[a-zA-Z]+.*$// ){	$_reigai=$&;}	# \hspace{3mm}などがあるとき、処理しない
	# if(length($_reigai)>0){print $_reigai."\n";}
	s/([\_\^√√])[ 	]*\{/$1\{/g;	#000612a
	while(s/([^\_\^√√][ 	]*)(\{.*)$/$1/ ){	#000612a
		$_new=$_new.$_;	$_=$2;	$nakami = &get_kakko_nakami_LtoR("quiet");	$_aft=$_;
		# $_=$nakami;	if( /^[ 	]*\{(.*)\}[ 	]*$/ ){	$_=$1;}	$_new=$_new.$_;
		$_=$nakami;	if( /^[ 	]*\{(.*)\}[ 	]*$/ ){	$_=$1;}	$_aft=$_.$_aft;
		$_=$_aft;
	}
	$_=$_new.$_.$_reigai;	s/^.//;

	$out = $_;
	$_ = $_org;
	return $out;
}
	#-----------------------------
	# _{}, ^{}以外の{}を削除(end)
	#
	#	{a_{bc}} を abc のように下付き処理を削除する
	#
	#		$_ = &rm_simotuki($_);
sub	rm_simotuki{
	my	($out, $_org);
 	my	($_new, $_tmp, $_aft);

	$_org = $_;
	$_ = $_[0];

	$_ = " ".$_;	# 下の処理は 先頭に1文字必要なので足す

	#未	●YD+XN → "YD" + "XN"　とする, 不十分990104j
	# while( s/([a-zA-Z])([a-zA-Z0-9])/$1 $2/g ){}
	s/([^\\a-zA-Z\{（])([a-zA-Z][a-zA-Z0-9]+)/$1\"$2\"/g;	# 英文：でも " が必要

	#	(dt|cos|sin|tan|exp|lim|Figure|figure|Fig|fig|Table|table|max|min)→ "..."不要,000801e
	s/\"([ 	]*)(dt|cos|sin|tan|exp|lim|Figure|figure|Fig|fig|Table|table|max|min)([ 	]*)\"/$1$2$3/g;

	# {a_{bc}} を abc のように下付き処理を削除する"

	$_new='';
	while(s/([^a-zA-Z0-9$def_txt_hensuuAll][a-zA-Z0-9$def_txt_hensuuAll])[ 	]*\_\{[ 	]*([a-zA-Z0-9 	$def_txt_hensuuAll]+[ 	]*)\}[ 	]*(.*)/$1/ ){	#a_{p 1} -> ap1, 000515a
		$_new=$_new.$_;	$_aft=$3;
		$_=$2;	s/[ 	]//g;	$_new=$_new.$_.' ';
		$_=$_aft;
	}
	$_=$_new.$_;
	s/([^a-zA-Z0-9$def_txt_hensuuAll][a-zA-Z0-9$def_txt_hensuuAll])[ 	]*\_[ 	]*([a-zA-Z0-9$def_txt_hensuuAll])([a-zA-Z0-9$def_txt_hensuuAll])/$1$2 $3/g;		# 000129a, 000515a, 000520g
	s/([^a-zA-Z0-9$def_txt_hensuuAll][a-zA-Z0-9$def_txt_hensuuAll])[ 	]*\_[ 	]*([a-zA-Z0-9$def_txt_hensuuAll])/$1$2/g;		# 000129a, 000515a, 000520g

	s/  / /g;	# 990104d

	s/^ //;			# 上の処理は 先頭に1文字足したので消す
	$out = $_;
	# $out = $_[0];
	$_ = $_org;
	return $out;
}

	#-----------------------------
	#	const を "const" に（txtの無変換）
	#		$caption = &ignor($1);
sub	ignor{	# \verb|..| を例外とする000611b
	my	($_1, $_2, $_new, $_org, $ptn);
	$_org=$_;	$_=$_[0];	$_new = '';
	while( s/\\verb([^a-zA-Z])(.*)$// ){	# \verb_aaa_, \verb0aaa0など a-zA-Z以外は\verbのあとの1文字として使える

		$ptn = $1;	$_2=$2;	$_1="\\verb".$ptn;	if( $_2=~s/^[^$ptn]*[$ptn]// ){	$_1=$_1.$&;}
		$_ = &ignor_hontai($_);
		$_new = $_new.$_.$_1;	$_ = $_2;
	}
	$_ = &ignor_hontai($_);
	$_new = $_new.$_;
	$_=$_org;
	return $_new;
}

sub	ignor_hontai{
	my	($out, $_org, $_ptn, $f, $mytmp);

	$_org = $_;
	$_ = $_[0];

	s/\([ 	]*(（[^）]*）)[ 	]*\)/$1/g;	#未	● (\ref{式ラベル}) → (（式ラベル）) となってしまうのを（式ラベル）とする。不完全(他のラベルも同じ処理をしてしまう), 990104g
	if( $H_eibun==0 ){	#000524b
		$f = 0;	# 0:無変換なし、1:無変換必要
		$_ptn = '';
		# | は tbl で使うので " で囲むとダメ??
		# & は tbl で使うので " で囲まない

		s/([^ 	])\\(LaTeX2e|LaTeX|TeX) ([^a-zA-Z0-9])/$1\\$2$3/g; 	# 000801g

		while(length($_)>0){
			# if( /^[\.\:\?\! 	\,\']/ ){				# " を付けても付けなくてもいいとき
			if( /^[\.\:\?\! 	\']/ ){				# " を付けても付けなくてもいいとき, 000707d'
			# }elsif( /^[\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\<\>]/ ){    # 先頭に$が必要か判断, <>追加 981101
			}elsif( /^[\|a-zA-Z0-9\\\_\^\+\-\*\(\)\[\]\{\} \=\<\>]/ ){    # 先頭に$が必要か判断, <>追加 981101, 990105c
				if( $f==0 ){
					$_ptn .= $H_ignor;	# ignor処理始まりの " ... 見やすい"
				}
				$f = 1;
			}else{
				if( $f==1 ){	# ignor処理終わりの " ... 見やすい")}TAO)}
					# $_ptn .= $H_ignor;
					$_ptn= &ignor_yurume($_ptn);
					$_ptn =~ s/(.*\"[^\"]*)(\\LaTeX2e|\\LaTeX|\\TeX)([^a-zA-Z0-9\_\"].*\"[ 	]*)$/$1\"$2\"$3/;	#000604b,000625s
					$_ptn =~ s/(.*\"[^\"]*)(\\LaTeX2e|\\LaTeX|\\TeX)(\"[ 	]*)$/$1\"$2\"$3/;	#000604b,000625s"
				}
				$f = 0;
			}
			s/^.//;
			$mytmp = $&;
			$_ptn .= $mytmp;
		}
		if( $f==1 ){
			# $_ptn .= $H_ignor;
			$_ptn= &ignor_yurume($_ptn);
			$_ptn =~ s/(.*\"[^\"]*)(\\LaTeX2e|\\LaTeX|\\TeX)([^a-zA-Z0-9\_\"].*\"[ 	]*)$/$1\"$2\"$3/;	#000604b,000625s"
			$_ptn =~ s/(.*\"[^\"]*)(\\LaTeX2e|\\LaTeX|\\TeX)(\"[ 	]*)$/$1\"$2\"$3/;	#000604b,000625s"
		}

		# (\ref{abc}) を（abc）に, 990104g
		# $_ = $_ptn;	s/\"\(\"(（[^）]+）)\"\)\"/$1/g;	$_ptn=$_;

		$_ptn=~s/([Ａ-Ｚａ-ｚ０-９]+)/\"$1\"/g;		# Ａ -> "Ａ"000801z"

		$_=$_ptn;
		while(s/\"\"//g){};
		$_ptn=$_;	#990105c"

		$out = $_ptn;
	}else{
		$out = $_;
	}
	$_ = $_org;
	return $out;
}

	#-----------------------------
	#	0-9,(),[],｛｝だけのとき ignor処理 "..." をしない, 000601a
sub	ignor_yurume{
	my	($out, $_org, $_ptn, $f, $mytmp);
	$_org=$_;	$_ptn=$_[0];
	if( $_ptn=~s/(.*)\"// ){
		$mytmp=$_ptn;	$_ptn=$1;	# $mytmp=)}TAO)} ... $mytmpは "..." の中身
		if( $mytmp=~s/^([^\{\}])([ 	\(\[｛\)\]｝])*// ){	# $mytmp2=) ,$mytmp=}TAO)}
			$mytmp2=$&;
			if( $1 =~/[ 	\(\[｛\)\]｝]/ ){	$_ptn=$_ptn.$mytmp2.$H_ignor;}	# $_ptn=...)"
			else{							$_ptn=$_ptn.$H_ignor.$mytmp2;}
		}else{								$_ptn=$_ptn.$H_ignor;}
	}else{					$mytmp=$_ptn;	$_ptn='';}

	if( $mytmp=~s/([ 	\(\[｛\)\]｝])*([^\{\}])$// ){
		$mytmp2=$&;
		if( $2 =~/[ 	\(\[｛\)\]｝]/ ){	$_ptn=$_ptn.$mytmp.$H_ignor.$mytmp2;}
		else{							$_ptn=$_ptn.$mytmp.$mytmp2.$H_ignor;}
	}else{
		$_ptn=$_ptn.$mytmp.$H_ignor;
	}

	$_ptn=~s/\"([0-9 	\(\[｛\)\]｝]*)\"([ 	\(\[｛\)\]｝]*)$/$1$2/;	# 0-9だけのとき "" を外す000801x"

	#	(dt|cos|sin|tan|exp|lim|Figure|figure|Fig|fig|Table|table|max|min)→ "..."不要,000801e
	$_ptn=~s/\"([ 	]*)(dt|cos|sin|tan|exp|lim|Figure|figure|Fig|fig|Table|table|max|min)([ 	]*)\"([ 	\(\[｛\)\]｝]*)$/$1$2$3$4/;

	$_=$_org;
	return $_ptn;
}
#000601a end"

	#-----------------------------
	# （abc）→ %(abc%)としたのを、"（abc）"にする,新規作成000707a
	#	s/\%\(/（/g;	s/\%\)/）/g;	#000623a
sub	ignor_ref_reigai{
	my	($_org,$aft,$tmp,$out);
	$_org=$_;	$_=$_[0];
	if(1){	# 000707aはなぜ"を追加するのか理解できないので、これを戻す。000813m
		s/\%\(/（/g;	s/\%\)/）/g;
	}else{
		while( s/\%\((.*)/\"（/ ){
			$aft = $1;
			# if( $aft=~s/\%\)(.*)/）\"$1/ ){"
			if( $aft=~s/\%\)(.*)// ){
				$tmp = "）\"$1";	$aft=~s/\"//g;
				$_ = $_.$aft.$tmp;
			}else{
				$_ = $_.$H_ignor.$aft;
				last;
			}
		}
	s/\%\(/\"（\"/g;	s/\%\)/\"）\"/g;
	s/\"\"//g;
	}
	$out = $_;	$_=$_org;
	return $out;
}

	#-----------------------------
	#	◯debug:tex2txt: eqnの中の\mbox{を"\mbox{"にする, 000801c
sub	ignor_mbox_reigai{	# \verb|..| を例外とする000611b,000801y
	my	($_org, $_1, $_2, $_new, $ptn);
	$_org=$_;	$_=$_[0];

	$_new = '';
	while( s/\\verb([^a-zA-Z])(.*)$// ){	# \verb_aaa_, \verb0aaa0など a-zA-Z以外は\verbのあとの1文字として使える

		$ptn = $1;	$_2=$2;	$_1="\\verb".$ptn;	if( $_2=~s/^[^$ptn]*[$ptn]// ){	$_1=$_1.$&;}
		$_=&ignor_mbox_reigai_hontai($_);
		$_new = $_new.$_.$_1;	$_ = $_2;
	}
	$_=&ignor_mbox_reigai_hontai($_);
	$_new = $_new.$_;

	$_=$_org;
	return $_new;
}

sub	ignor_mbox_reigai_hontai{
	my	($_org,$aft,$tmp,$tmp1,$out,$nakami);
	$_org=$_;	$_=$_[0];
	$aft='';
	while( s/(.*)(\\mbox)[ 	]*(\{)/$3/ ){
		$tmp = $1;	$tmp1=$H_ignor.$2;
		$nakami = &get_kakko_nakami_LtoR('');
		$nakami =~ s/^\{/\{\"/;
		$nakami =~ s/\}$/\"\}\"/;
		$aft = $tmp1.$nakami.$_.$aft;
		$_ = $tmp;
	}
	$_ = $_.$aft;

	$out = $_;	$_=$_org;
	return $out;
}

	#-----------------------------
	# （abc）(tex)→%(abc%)としたのを、（abc）にする,新規作成000707h
sub	ignor_ref_reigai2{
	my	($_org,$aft,$tmp,$out);
	$_org=$_;	$_=$_[0];

	s/\%\(/（/g;	s/\%\)/）/g;

	$out = $_;	$_=$_org;
	if(/LaTeX/){print $out."000\n";}
	return $out;
}

	#-----------------------------
	#	\ref{abc} を（abc）に
	#	(\ref{abc}) を（abc）に ... NG
	#	未：\ref{ ... } の中は "ignor" の処理しないことが未
	#		$_ = &ref($_);
sub	ref{
	my	($out, $_org, $_ptn, $i, $mytmp);

	$_org = $_;
	$_ = $_[0];
	# if(/\\ref/){print $_."\n";}	# $_=\ref{abc}) と \ref が先頭になっていて (\ref{ を見付けられない), 990104g

	while( s/(.*)\\ref[ 	]*\{// ){	# $_='aaa \ref{ bbb} ccc' → $_   =' bbb} ccc'
		$mytmp=$_;	$_=$1;
		if( s/\([ 	]*$// ){	$f = 1;}
		else{					$f = 0;}
		$_ptn = $_."（";						#						  → $_ptn='aaa（'
		$_ = $mytmp;
		$i = 1;
		while( s/^.// ){
			if(    $& eq '}' ){	$i--;}
			elsif( $& eq '{' ){	$i++;}
			if( $i == 0 ){
				$_ptn = $_ptn."）";
				last;
			}
			if( $_ptn ne $H_ignor ){		# ignor処理を無効にする(本当の"は”に変換済)
				$_ptn = $_ptn.$&;
			}
		}
		if( $f==1 ){	s/^[ 	]*\)//;}
		$_ = $_ptn.$_;
		if( $i!=0 ){	&print_($_."えらー in ref\n");}
	}


	$out = $_;
	$_ = $_org;
	return $out;
}
#---------------------------------




#---------------------------------
#	eqn 特有の関数
	#-----------------------------
	#	common function
sub	print_OUT_euc{
	print OUT $H_OUT;
}

sub	print_OUT{	# 変換元ファイルの日本語コードでファイル出力000723a
	# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';}
	if(	   $H_JCODE eq 'euc' ){		print OUT $H_OUT;}
	# elsif( $H_JCODE eq 'sjis' ){	print OUT Jcode->new($H_OUT)->h2z->sjis;}
	# elsif( $H_JCODE eq 'jis' ){		print OUT Jcode->new($H_OUT)->h2z->jis;}
	# elsif( $H_JCODE eq 'utf8' ){	print OUT Jcode->new($H_OUT)->h2z->utf8;}
	# elsif( $H_JCODE eq 'sjis' ){	&jcode::convert(\$H_OUT,'sjis','euc', "z");   print OUT $H_OUT;}	#000723f
	elsif( $H_JCODE eq 'sjis' ){	print OUT $H_OUT;}	#000723f
	# elsif( $H_JCODE eq 'jis' ){		&jcode::convert(\$H_OUT,'jis','euc', "z");   print OUT $H_OUT;}	#000723f
	else{							print OUT $_[0];}
	# if($H_PERL_VER==1){	eval 'I18N::Japanese;';}
}

sub	print_{	# OSの日本語コードで画面出力000723a, 000723c
	my	($tmp);
	# if($H_PERL_VER==1){	eval 'no I18N::Japanese;';}
	if(	   $H_OS eq 'Linux' ){	print $_[0];}
	# else{						print Jcode->new($_[0])->h2z->sjis;}	# MacとMS-Winは SJIS
	# else{	$tmp=$_[0];	&jcode::convert(\$tmp,'sjis','euc', "z");   print $tmp;}	# MacとMS-Winは SJIS, 000723f,000814
	else{	$tmp=$_[0];	print $tmp;}	# MacとMS-Winは SJIS, 000723f,000814
	# if($H_PERL_VER==1){	eval 'I18N::Japanese;';}
}

sub	to_euc{	# EUCに変換000723a,000723d
	#	$_ = &jcode::convert($_,'euc',$H_JCODE, "z");
	#	if($H_PERL_VER==1){	eval 'no I18N::Japanese;';}	&jcode::convert(\$_,'euc',$H_JCODE, "z");	if($H_PERL_VER==1){	eval 'I18N::Japanese;';}#000723f,000723h

	#	if( $H_JCODE eq 'sjis' ){		$_ = &Jcode::convert($_,'euc','sjis', "z");}
	#	elsif( $H_JCODE eq 'jis' ){		$_ = &Jcode::convert($_,'euc', 'jis', "z");}
	#	elsif( $H_JCODE eq 'utf8' ){	$_ = &Jcode::convert($_,'euc','utf8', "z");}
}



#------ 全角文字のLaTeX文字への置換えの処理(begin) ---------
#初期設定

#	&define_LaTeXmoji;
sub	LaTeXmoji_tex2txt{			# \theta を θ に
	my	($i, $tmp);

	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
		# s/$def_tex_hensuu[$i]/ $def_txt_hensuu[$i]/g;	# 000129d:comment
		s/$def_tex_hensuu[$i]$/ $def_txt_hensuu[$i]/;	# 000129d
		s/$def_tex_hensuu[$i]([^a-zA-Z])/ $def_txt_hensuu[$i]$1/g;	# 000129d
	}
	for($i=0;$i<=$#def_txt_moji;$i++ ){
		# s/$def_tex_moji[$i]/ $def_txt_moji[$i] /g;	# 000128aコメント
		s/$def_tex_moji[$i]$/ $def_txt_moji[$i]/g;	#●積分の\intが ∈ t になる。→∫にする, 000128a
		s/$def_tex_moji[$i]([^a-zA-Z])/ $def_txt_moji[$i]$1/g;	#●積分の\intが ∈ t になる。→∫にする, 000128a
	}

	s/(＾|\~|￣)[ 	]*/$1/g;	# ~ θ を ~θ に

	s/\\(cos|sin|tan|exp|lim)([^a-z])/ $1 $2/g;	# $...$とすべきもの000601b

	#◯tex2txt:debug:   \mbox{\"{E}} (tex) → \mbox {\”E} (txt) → Ё, 000625i
	s/\\mbox[ 	]*\{[ 	]*\\[ 	]*[\"”][ 	]*\{[ 	]*E[ 	]*\}[ 	]*\}/Ё/g;
	s/\\mbox[ 	]*\{[ 	]*\\[ 	]*[\"”][ 	]*E[ 	]*\}/Ё/g;
	s/\\[ 	]*[\"”][ 	]*\{[ 	]*E[ 	]*\}/Ё/g;
	s/\\[ 	]*[\"”][ 	]*E/Ё/g;
	s/\\mbox[ 	]*\{[ 	]*\\[ 	]*[\"”][ 	]*\{[ 	]*e[ 	]*\}[ 	]*\}/ё/g;
	s/\\mbox[ 	]*\{[ 	]*\\[ 	]*[\"”][ 	]*e[ 	]*\}/ё/g;
	s/\\[ 	]*[\"”][ 	]*\{[ 	]*e[ 	]*\}/ё/g;
	s/\\[ 	]*[\"”][ 	]*e/ё/g;

	# y/。、/．，/;	#000524a"
	# y/[０-９]/[0-9]/;	# dollarの処理の後にすべき

	s/\\cdots/・・・/g;
	# s/\磁\磁\磁/\\cdots /g;	#error in unix
	s/\\ldots/\.\.\./g;
	s/\\pm/\+\-/g;
	s/\\mp/\-\+/g;
	s/\\ast/\*/g;	# s/\*//g; の前に処理するように変更, 981119
	s/\\Leftrightarrow/←→/g;
	s/\\Updownarrow/↑↓/g;

	# 000801z	y/Ａ-Ｚａ-ｚ０-９/A-Za-z0-9/;	#●全角英数字を半角英数字に変換する, 981123c
	&abs_norm_tex2txt;

	# ●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ これも文字化けがひどくて読めない 200624
	if( /(・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|①|②|③|④|⑤|⑥|⑦|⑧|⑨|⑩|⑪|⑫|⑬|⑭|⑮|⑯|⑰|⑱|⑲|⑳|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|≡|・ｽ・ｽ|∫|∮|√|⊥|∠|∟|⊿|∵|∩|∪|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|遑ポ遑楯遑ｨ|・弓博|遖ｱ|箞|遽慾邁－ｶ｡|邊ｼ|邉怖・|・|・|・|・)/ ){ # unixで表示できない外字一覧

		$H_OUT='% 外字"'.$1.'"は表示と印刷ができないかも？'."\n";	&print_($H_OUT);
		if( $LATEX_MODE==$H_NORMAL ){	&print_OUT;}	#000707c
	}
}

#	○tex2txt:debug: ｝→\}→"｝", texファイルにαなどあると、"α"とする。000707e
sub	LaTeXmoji_reigai{
	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
		s/($def_txt_hensuu[$i])/\"$1\"/;
	}
	for($i=0;$i<=$#def_txt_moji;$i++ ){
		s/($def_txt_moji[$i])/\"$1\"/;
	}
	s/\"\"//g;
}

# 絶対値、ノルムの LaTeX への変換"
#   数式    ：txtの書き方   ：LaTeX
#   絶対値  ：｜x｜     ：  |x|
#   ノルム  ：窶堀窶髦     ： \|x\|
#   ノルム  ：窶堀窶髦     ： \|x\|
#   1ノルム ：窶堀窶髦1    ： \|x\|_1
#   2ノルム ：窶堀窶髦2    ： \|x\|_2
#   ∞ノルム：窶堀窶磨蜀   ： \|x\|_\infty
#	980917, 990104a,000801a,000801l
sub	abs_norm_tex2txt_hontai{ # 文字化け解読不能のため、消してもいいかも？ 200624
	my	($_1,$_2,$_3,$_4,$_5,$aft);
	# s/\|[ 	]*([^\|]*)[ 	]*\|[ 	]*(\_)*[ 	]*(1|2|∞)*/｜$1｜$2$3/g;
	# s/(\\｜)([^｜]*)(\\｜)[ 	]*(\_)*[ 	]*([12∞]*)/窶髦$2窶髦$5/g;
	$aft='';
	while( s/(.*)\\\|([^\|]*)\\\|[ 	]*(\_)*[ 	]*([12∞])*// ){ # (.*)\|(.*)\|(\_)([12\infty])*
		$aft = $_.$aft;	$_1=$1;	$_2=$2;	$_3=$3;	$_4=$4;
		$_2=~s/^[ 	]+//;	$_2=~s/[ 	]+$//;
		$aft = "窶髦".$_2."窶髦".$_4.$aft;	$_ = $_1;
	}
	$_ = $_.$aft;
	$aft='';
	while( s/(.*)\|([^\|]*)\|[ 	]*(\_)*[ 	]*([12∞])*// ){
		$aft = $_.$aft;	$_1=$1;	$_2=$2;	$_3=$3;	$_4=$4;
		$_2=~s/^[ 	]+//;	$_2=~s/[ 	]+$//;
		$aft = "｜".$_2."｜".$_3.$_4.$aft;	$_ = $_1;
	}
	$_ = $_.$aft;
	# if(/[窶磨b]/){print $1."-".$2."-".$3."-".$4."-".$5."-".$&."aaaa  ".$_."\n";}
}

sub	abs_norm_tex2txt{	# \verb|..| を例外とする000611b
	my	($_1, $_2, $_new, $ptn);
	$_new = '';
	while( s/\\verb([^a-zA-Z])(.*)$// ){	# \verb_aaa_, \verb0aaa0など a-zA-Z以外は\verbのあとの1文字として使える

		$ptn = $1;	$_2=$2;	$_1="\\verb".$ptn;	if( $_2=~s/^[^$ptn]*[$ptn]// ){	$_1=$_1.$&;}
		&abs_norm_tex2txt_hontai;
		$_new = $_new.$_.$_1;	$_ = $_2;
	}
	&abs_norm_tex2txt_hontai;
	$_ = $_new.$_;
}
#------ 全角文字のLaTeX文字への置換えの処理(end) ---------




#---------------------------------
#	初期設定

#---------------------------------
sub	init{
	&initconnect_kakko_1gyou;
	&initset_begin_or_end_1gyou;
	&initgetLATEX_MODE;
	&init_begin_verbatim;
	&init_verbatim_tex2txt;
	&initconnect_verb_1gyou;
	&define_LaTeXmoji_tex2txt;
}

#------ LaTeX 記号、文字の定義(begin) ---------
#&define_LaTeXmoji;
#	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
#		s/$def_txt_hensuu[$i]/$def_tex_hensuu[$i] /g;
#	}
#
sub	define_LaTeXmoji_tex2txt{
	my( $i, $_org, $_tmp);

	$_org=$_;
	&define_LaTeXmoji;
	for($i=0;$i<=$#def_tex_hensuu;$i++ ){
		$_=$def_tex_hensuu[$i];
		s/([\\\!\"\#\$\%\&\'\(\)\~\=\-\~\^\|\`\@\[\{\]\}\:\*\;\+\_\/\?\.\>\,\<])/\\$1/g;
		$def_tex_hensuu[$i]=$_;
	}
	for($i=0;$i<=$#def_tex_moji;$i++ ){
		$_=$def_tex_moji[$i];
		s/([\\\!\"\#\$\%\&\'\(\)\~\=\-\~\^\|\`\@\[\{\]\}\:\*\;\+\_\/\?\.\>\,\<])/\\$1/g;
		$def_tex_moji[$i]=$_;
	}
	$_=$_org;
}
#------ LaTeX 記号、文字の定義(end) ---------"



#---------------------------------
#	共通で使う汎用の関数

#---------------------------------
# 変数が文字列を含むか判定する

#	&find('abc',$x)
#		$x が 'abc' を含むとき 1 を返す、含まないとき 0 を返す
sub	find{
	my( $_org, $myptn, $f );

	if(0){
		$myptn = $_[0];
		$_org = $_;	$_ = $_[1];

		if( /$myptn/ ){	$f=1;}
		else{			$f=0;}

		$_ = $_org;
		return $f;
	}else{
		return ($_[1]=~/$_[0]/)
	}
}


#---------------------------------
#	ヘッダファイル（defineなど）
#---------------------------------
sub	HeaderFile_tex2txt{
	my	($i);

	$i=0;
	$H_EQN		= $i;	$i++;	#0 式のブロック
	$H_FIG		= $i;	$i++;	#1 図のブロック
	$H_TBL		= $i;	$i++;	#2 表のブロック
	$H_ITEM		= $i;	$i++;	#3 箇条書のブロック
	$H_BIBTEM	= $i;	$i++;	#4 参考文献のブロック
	$H_THEOREM	= $i;	$i++;	#5 定理などのブロック
	$H_BEGINNING= $i;	$i++;	#6 はじまりのブロック(先頭行から\begin{document}まで)
	$H_NORMAL	= $i;	$i++;	#7 本文のブロック(要約も)
	# $H_EQNinITEM= $i;	$i++;	# 箇条書の中の式のブロック
	# $H_EQNinTBL = $i;	$i++;	# 表の中の式のブロック
	# $H_UNKNOWN	= $i;	$i++;	# 何か分からないブロック

	$H_HENKAN_COMMAND = '\\\begin|\\\end|\\\documentstyle|\\\title|\\\author|\\\date|\\\listof[a-z]*|\\\tableofcontents|\\\[sub]*section|\\\renewcommand|\\\ref|\\\newtheorem';
	# $H_HENKAN_COMMAND = '\\\begin|\\\end|\\\documentstyle|\\\title|\\\author|\\\date|\\\listof[a-z]*|\\\tableofcontents|\\\[sub]*section|\\\renewcommand|[\( 	]*\\\ref|\\\newtheorem';
	# print $H_HENKAN_COMMAND."\n";
	# "\\\\begin\|";

	# tex のコメント % の出力モード
	$H_PERCENT	= 0;	# % のコメント行を出力しない
	# $H_PERCENT	= 1;	# % txt2tex のコメント行と % だけのコメント行を出力しない
	# $H_PERCENT	= 2;	# % のコメント行を出力する


	# tex2txt の動作モード
	# $H_MODE	= 0;	# texソースの整理のみ
	$H_MODE	= 1;	# txtへ変換
}
#************************************************************************
#************************************************************************
#end of ayato tex2txt.pl
#************************************************************************
#************************************************************************




#************************************************************************
#************************************************************************
#beginning of matomato txt2tex.pl
#************************************************************************
#************************************************************************

#sub	print_rireki{
#print <<'PRINT_RIREKI';
#####################################################
#	txt2tex.pl 変更点
#####################################################
#
#$VER=   'まとあと txt2tex/tex2txt 0.29, たおくま, 000507';#■□■□■□■□■□■□■□■□
#	●dx/dtを意味するx dotの書き方を readme.txt に書く ... 式以外では \.{x}, 式環境では \dot{x}, 000503a
#	●、→，と。→．の変換を止める(やりたいときは#define文で対応させる). 000504a
#	●\documentstyle[a4j,psbox]{jarticle}とa4j.styを追加, 000504b
#	●\begin{table*}[tbh]と[t]から変更, 000504c
#	●段落の字下げの記号を全角スペース　に加えて半角スペース2個  でもいいようにする, 000504d
#	●箇条書の全角スペース　に加えて半角スペース2個  でも記号があれば箇条書処理する, 000504e
#	●debug: 式の中に"："と書くと\cdotsと変換される。→変換しない, 000504f
#	●/^\t表：$/のとき\begin{tabular}...\end{tabular}だけ書いて、\begin{table*}をしない。(表番号、キャプションなし、文字と同じ扱い), 000504g
#	●/^\t図：$/のとき\psbox[xsize=\hsize]{yst.eps}だけ書いて、\begin{figure}[t]をしない。(図番号、キャプションなし、文字と同じ扱い), 000504h
#	●表：の機能アップ, 下表も書けるようにする, 000504i
#		-----
#		a | b ← これを書けるようにする(縦線なしの表)
#		--+--
#		c | d
#	●debug: 表の中に\limなどがあると/*1*/に変換されて$$の中から外れる→""だけ無変換にするサブルーチンを作ってtblで使う, 000504j
#		→ 本文中のa+\limなどがa+/*1*/に変換され、$a+$\limと$$の中から外れる→/*1*/に変換するコマンドを限定する, 000504j
#	●仕様変更: 図の書き方変更, 000505a
#		図：キャプション（ラベル,file=ファイル名） ... file = ファイル名.eps
#			↓
#		図：キャプション（ラベル,filename.eps,上下ここ頁,1.0倍） ... キャプション省略時\begin{figure}[t]なし
#	●仕様変更: 表の書き方追加, 000505b
#		表：キャプション（ラベル,上下ここ頁,中左右） ... キャプション省略時\begin{figure}[t]なし
#	●debug: 図：or 表：のあとに% ... があるとうまく処理できない→ % を前の行に書いてしまう。000505c
#	●式と式の間にタブのみの行があると、読み飛ばす。（従来は && \nonumber としていた）, 000506a
#	●行列の後ろに（ラベル,[中左左）が書かれているとき、\left[ \begin{array}[cll] とする, 000506b
#	●debug: MP^b → {M_{P}}^b → {M_{P}^b}, 000506c
#	●C言語の#define文の処理追加, 000506d
#		#define	DEBUG	1		 のとき、#if DEBUG で #if 0 の処理ができるようにする

#		#define	kg/cm	"kg/cm"	 のとき、置換する

#		#undef	kg/cm			 などのとき、以降の行の置換をやめる

#	●$...$を自動的に付けて、下付き、分数処理することを止めれるようにする。, 000506e
#		#define	英文：		 のとき、a+b→$a+c$の処理をしない。（$a+b$と書くようにする）
#		#undef	英文：		 のとき、デフォルトに戻す
#	●sice.styのときは、abstractのあとに\maketitleにしないといけない(普通の逆) → sice.styのとき000408aの行をコメントする, 000507a
#	 		jarticle.sty				sice.sty
#		・\maketitleのあとにabstract → abstractのあとに\maketitle
#		・\title+\author+\dateが必要 → \jtitleがあればいい
#	●txt2tex.pl + main.pl + tex2txt.pl(ver. 0.10α)→txt2tex, 000507b
#		"txt2texの使い方"を作成，"txt2tex --help" で見れるようにする．
#		現状、cp file.txt txt2tex.dat;perl txt2tex.pl → txt2tex file.txt とできるように変更する。
#
#$VER=   'txt2tex.pl 0.28, 000502';#■□■□■□■□■□■□■□■□
#	●debug: ，LaTeX が，\LaTeX にならない 000422a
#	●debug: β1(t)/Φa(t) → β1{\frac{t}{Φa}}(t) : {\beta _{1}}{\frac{t}{{\Phi _{a}}}}\left(t\right), 000422b
#	●debug: a^~b ->a^\tilde b -> a^{\tilde b} ------ ＾a, ~b, ￣ {c+d} を {＾a}, {~b}, {￣{c+d}}にする 000426a
#	●debug: a/b や a などだけの文書（章：なし）の\begin{document}の位置が変, 000427a
#	●debug: 図：図の例（file=fig_ex1） のとき，図（fig_ex1）で参照できない。, 000428a
#	●debug: 式の中にダブルクォーテーション に囲まれた = など " = " があるとき && が２重につく -> 式処理で&&を付ける前に "" を/*1*/にする, 000428b
#	"ex. 　Abc1: あああ"
#		↓
#	\begin{eqnarray}
#	    &&ex. 　Abc1    &:& あああ
#	        \nonumber
#	\end{eqnarray}
#
#	●debug: ( や ) を変換するとき $($ や $)$ として カッコの数の warning を吐いている。→うっとうしいのでカッコ１個だけのときはそうしない, 000428c
#	●debug: % の処理のバグ -> %があるかもしれない /*1*/ を{}の中に入れない。000428d
#	表：キャプション	% ← 参照は、（表：キャプション）
#		↓
#	\caption{キャプション   % ← 参照は、（表：キャプション）}
#	\label{表：キャプション % ← 参照は、（表：キャプション）}
#	●debug: #"define"文 → \#define文 に変換する，\label{#define文} → LaTeXエラーになるので\label{＃define文} に変換する, 000430a
#		本文では、# → \#
#		ラベルは、# → ＃ と変換する。
#	●debug: 章：のあとの 目次：→\tableofcontentsに変換されない → 変換する, 000430b
#	●debug:下のとき、118Ｃのように行番号が残る, 000430c
#	\begin{verbatim}
#	    \documentstyle[psbox]{jarticle}
#	\end{verbatim}
#				↓
#	\begin{verbatim}
#	    118Ｃ\documentstyle[psbox]{jarticle}
#	119Ｃ\end{verbatim}
#	●debug: "（eqn:5）縲怐ieqn:7）式" → ""(\ref{eqn:5})"縲鰀"(\ref{eqn:7})" → （eqn:5）縲怐ieqn:7）式, 000430d
#	●debug: ∝ → \propt → \propto, ☆→\Star→\star, 000430e
#	●debug: ＾~￣α → \hat \tilde {\bar \alpha } → \hat {\tilde {\bar \alpha }}, 000430f
#	●debug: Ё, ё → $\$"${E}$, $\$"${e}$ →  \"{E}, \"{e}, $"$を"に変換する, 000501a
#	●debug: Ё, ё → \"{E}, \"{e} これらは、$$とかeqnarrayで使うとlatex warning
#		latex warning 回避策：	本文中で$を付けない or eqnarrayでは\mbox{}を付ける, 000501b
#		latex warning の問題点：問題なし  → 000501bにより latex warning 自体が発生しないので問題なし
#	●debug: П \bigsqcap, Ц  \bigsqcup, Ээ \SuchThat (これらのコマンドは存在しない)
#			→ П \prod, Ц \coprod, Ээ \ni, 000502a
#	●debug: 行列\n行列= ... → 行列\n&& 行列= ... → 行列\n行列&=&... , 000502b
#	●debug: "”" → """ → "”", ”→”→", 000502c
#	●debug: $)$, $($は，不細工なので ), ( と$を外す．, 000502d
#
#$VER=   'txt2tex.pl 0.27, 000408';#■□■□■□■□■□■□■□■□
#	●\bar {y_{p}} → {\bar y}_{p}, 000214a
#	●式ラベルが （）のときdviに式番号が出るようにする（ \labelも\nonumberもつけない ... latexでは式番号だけつく）, 000218a
#	●=,:に加えて>,<,≧,≦,≡,≠の前後に & を書く．, 000218b
#	●式に &...& が書かれているとき、= → &=& としない, 000219a
#	●eqnarrayの , を ,\ にする, 000219b
#	●参考文献：が複数あると、2つめから変換されない → warningを出して、変換する, 000219c
#	●&tbl で | なしで横幅を揃えた表が書けない → & のとき | なしにする, 000220a
#	●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a
#	  → とりあえず Error を出すだけ
#	 1. 行列関連：下の1行の行列のとき無限ループになる→きちんと修正して Warning を出す
#		a =／ x ＼
#	 2. 行列関連：下のとき(／で終らない)無限ループになる→きちんと修正して Warning を出す
#		a =／ x ＼
#		   ＼ y  |
#	 3. 行列関連：下のとき( , の数が違う)、latex warning → dvi ファイルはできるし、latex でwarning吐いてミスがわかるが、latex の行番号では元の行が分からないのでチェックは要る(eqnMatKakkoに) 000309a
#		a =／x    ＼
#		   ＼y , z／
#	 4. 行列関連： 行列の | の数がおかしい(まちがえて||a||∞と書いたとき)とき Warning を出す ←未
#	●行列の=に &=& を付け足す処理のデバッグ, 000227b
#	●行列を挟む括弧の処理のデバッグ, 000303a, 000327a
#	●全角のローマ数字を LaTeXmoji に変換する, 000309b
#		・小文字  → {\romannumeral 2}	←　DOS/VのSJISではいいが、linuxでは文字化けする

#		・大文字 Ⅵ → {\expandafter\uppercase\expandafter{\romannumeral 6}}
#	●空のファイルをtxt2texすると\end{document}だけのtexファイルになり、\begin{document}が書かれない←きちんと書く, 000309c
#	●\titleなど何もないのに\maketitleするとlatex warning　← このとき\maketitleを書かない, 000317a
#		\maketitleは、\title,\authorがないとlatex warning、\dateがないと日付が自動的に書かれる

#			→ \title, \author, \date, abstractのいずれかがあると\maketitleを書き、上記３つのどれかないとき\date{}などをかく
#	●debug: abstractの中身が\begin{abstract}と\end{abstract}の中からはみ出す, 000403a
#	●debug: \maketitleのあとに、\begin{abstract}を書かないと p. -1 にアブストラクトだけ書かれる。→ この順序にする, 000408a
#	●debug: 要約：木村 だけのファイルのとき\end{abstract}が書かれない。→ 最後に改行を足す, 000408b
#	●debug: \label{eqn:def:Zi1,Zi2} -> \label{eqn:def:Zi1,\ Zi2}, 000403b
#	●debug: {\bar \hat y} -> {\bar {\hat y}}, 000403c
#	●DOSの perl がバージョンアップでUNIXと等価?になったので DOS or UNIX の $OS を削除, 000408c
#
#$VER=   'txt2tex.pl 0.26, 000213';
#	●"lim"_{t→∞} y(t) → lim_{t→∞} y(t)
#	●get_BEGINNINGのバグ, 000210a
#		題名："txt2tex.pl ver 0.026"開発用のテストファイル

#		→ "\title${$txt2tex.pl ver 0.026開発用のテストファイル}
#	● %ab が %$a_b$ にならないように、コメントはそのまま放っておく. 000210b
#	●参考文献のラベルバグ，（参：参:"step-PE-1"）→（参：参:${s_{tep}}-{P_{E}}-1$）を\cite{参：参:step-PE-1}に修正,000210c
#	●参考文献の参照ラベルを\cite{abc}と書くべきなのに\ref{abc}にしている, 000210d
#	●箇条書にラベル（A:4）が書かれているとき、それをラベルにする, 000210e
#		（"A:2StepIdent"）→（$A$:$2{S_{tepIdent}}$）と新規に\label{A1}が作られる

#		これを\label{A:2StepIdent}, \ref{A:2StepIdent}に修正
#	●dollar $ の処理バグ, 000210f
#		図書, "pp. "~"84--85, (1994)" → 図書$, pp. \tilde $84--85, (1994) → 図書, pp. $\tilde$84--85, (1994)
#		$A $and$ B$ → $A$ and $B$ にする

#	●次に全角スペースがないのに\end{eqnarray}\nや\end{figure}\nや\n\begin{figure}[t]となるので、\nを\n%にする, 000211a
#	●定理：、補題：のラベルが（定理1："StepIdent"）のように 1 があってもOKとする。000211b
#	●行列のとき \vdots←：, \ddots←・.に変換する, 000211c
#	●表：のラベルが変換されない, 000212a
#	●表：の$a_b$の処理がされない, 000212b
#	●表：の行番号が残っていた, 000212c
#	●表：で$a  \\$はjlatex error(問題なくdviファイルはできるが)なので$a$	\\に修正, 000212d
#	●表：で"\multicolumn{|c|}"の|を&に変換しないように、あらかじめ/*1*/に変換する, 000212e
#	  これで、表：で表の入れ子のとき、&の数をうまく数えられないバグをとれる

#	●\tilde, \hat, \barが$\tilde$になることがある。(引数なしのlatex error)→ $\tilde{}$とする, 000212g
#	●行列で x&=&matrix \\ matrix → x&=&matrix \\ &&matrix とする, 000212h未
#	●（4章：同定則）→\ref{章：同定則}, 000213a
#	●式の中の ｛...｝ → \left\{...\right\}, 000213b
#	●定理：、補題：、証明：のラベルの位置が\newtheoremの後 → \begin{theorem}の後に, 000213c
#	  \newtheorem{theorem}{定理} は１回だけ書く
#	●\varphi (s), \maxが$$の中に入らない：\varphi $\left(s\right)$ → $\varphi \left(s\right)$, 000213d
#	●（）の入れ子：中の（）を()に変換して対処, 000213e
#	6.1節：定理"1"の"1)"の証明（4節：定理（定理：StepIdent）の1)の証明）
#	→ \label{節：定理"\ref{定理：StepIdent}"の1)の証明} → \label{節：定理(定理：StepIdent)の1)の証明}
#	●式の中の ： → \vdots, 000213f
#	●bibitemにスペースが使えない。\bibitem{参：参:M_AB is Seisoku} → \bibitem{参：参:M_AB　is　Seisoku}, 000213g
#	● max_{x1} を \max\limits_{x_1} に変換する(min, limも), 000213h
#	●Fig.4 → Fig. 4 (Figs.も), Table1 → Table 1, 000213i
#	●Figs. 3,4 → Figs. 3, 4, 000213j
#
#$VER=   'txt2tex.pl 0.25, 000206';
#	●&sectionの全面改訂 ... 題名などはじまりの処理を完全に書き直して、この処理を &get_BEGINNING に融合, 000206a
#	&get_BEGINNING の仕様
#		1.\documentstyle[psbox,because]{jarticle} を書く
#		2.\def\thereforeと\def\becauseを書く
#		3.\setlength{\headheight}などを書く
#		4.題名：リング	→　\title{リング}に変換
#		5.作成：くま	→　\author{くま}に変換
#		6.\begin{document}を書く
#		7.目次：，表目次：，図目次	→　\tableofcontents，\listoftable，\listoffiguresに変換
#		8.要約：これこれ	→　\begin{abstract}これこれ\end{abstract}に変換
#		9.日付：いついつ	→　\date{いついつ}に変換
#未		・題名：，作成：，要約：，日付：のいずれかがあるとき\maketitleを書く。
#未			→　作成：なしで\maketitleを書くとき\author{}を書く（ないとlatex error）
#未		・'○○：'の順番がlatex error を引き起こすときだけ順序を入れ換える。あとは"\etitle{...}"などをそのまま出力
#			確認したlatex errorは以下の通り。
#未				・\？？？のあとに\？？？がくるとき。
#		・beginning処理の終了条件は、'章：' or 空行の次の行が\aaa以外 or １行目から'題名：'や\aaaや空行など以外のとき
#		・'○○：'の終わりの条件は、空行または'○○：'の行のとき。
#		・\documentstyleや'○○：'が２重に定義されているとき、後の定義を優先し、warningを出して前のを無視する。
#		　　→　\verbや\begin{verb}の中身を無視する。
#	●&verb新規作成...\verbの次の１文字から、次に現れるまで"で囲う, 000206b
#	●&verbatimデバッグ...１行に\begin{verbatim}あいう\end{verbatim}があるときの処理追加 , 000206c
#
#$VER=   'txt2tex.pl 0.24, 000201';
#	●txtに\documentstyleが書かれていると書き足さない, 000201a
#	●はじめに\Vol{}があるとき要約：が変換されない→変換する, 000201b
#	●\begin{keyward}の位置が変になる, 000201c
#		→　要約：のあとに"\begin{keyward}"\n"KEYWARD"\n"\end{keyward}"があると、KEYWARDから本文とみなしてしまう。
#
#txt2tex.pl 0.23, 000123
#	UNIX版0.21DOS版0.22とを融合

#
#txt2tex.pl 0.22, 991028
#	Select DOS or UNIX, see $OS
#
#txt2tex.pl 0.21, 990103
#	●図の書き方追加→図：キャプション（ラベル,file=ファイル名） ... file = ファイル名.eps, 990103a
#
#txt2tex.pl 0.20, 990102
#	●1-3節：、定理２：なども1-3、２などを無視して変換できるようにする, 990102a
#	●表：の横線に___に加えて---もいいようにする． 990102b
#	●（"eqn:aaa"）の中の " を無視する． 990102c
#	●式ラベルの文字制約を無くす,（eqn:aaa=A_B[]()）もOK, 990102d
#	●表の書き方 \t表： → [\t]*表：に変更, 990102e
#	●abs,norm,行列関連： ||a||∞が行列の中にあると、行列の | と区別できない
#		→ ||a||∞ の書き方を窶紡窶磨№ﾉ変更, 990102f
#
#txt2tex.pl 0.19, 981219
#	● ~idq  →  {\tilde i_{dq}} になるように変更, 981219a
#	● ￣idq  →  {\bar i_{dq}} になるように変更, 981219b
#
#txt2tex.pl 0.18, 981215
#	●&get_BEGINNINGで本文のはじまりを探す処理で、"%aaa" も本文として判断してしまう。
#		→ コメントのみの行を本文とみなさない, 981215a
#	●"\t表目次：" を式にしてしまう。 → タブを削除, 981215b
#
#txt2tex.pl 0.17, 981214
#	●"	表："の行と, "____" の行の間に先頭タブのないコメント行などがあると式と認識する

#		→ コメントのみの行の改行も削除する, 981214a
#
#txt2tex.pl 0.16, 981210
#	●1/√{La Lf} → 元 {\frac{1}{\sqrt }}{{L_{a}} {L_{f}}} → {\frac{1}{\sqrt {L_{a}} {L_{f}}}} になるように\sqrtを{}で囲むように変更, 981210a
#	●全角｝を\}に変換する, 981210b
#
#txt2tex.pl 0.15, 981209
#	●1/n! → 元 \frac{1}{n} ! → \frac{1}{n!}になるように &frac に ! を追加, 981209a
#	●f^{(n)}/n! → 元 f^{\frac{(n)}{n!}} → \frac{f^{(n)}}{n!} になるように変更, 981209b
#	● ＾idq  →  元 \wedge {i_{dq}} → {\hat i_{dq}} になるように変更, 981209c
#
#txt2tex.pl 0.14, 981206(あのにゃん生誕！！！, am 6:56, 3205g)
#	●今まで√{abc}と書く仕様だったが、√(abc), √abc でもいい仕様に変更 → あのにゃん

#
#txt2tex.pl 0.13, 981205
#	●% txt2tex Bug: 現在の行番号を見失いました/*10*/
#		→ \newtheoremを出力するとき$H_nextを追加, 981205a
#		→ \begin{verbatim} ... \end{verbatim} を出力するとき$H_nextを追加, 981205b
#	●&eqnのバグ... &=& となるべきなのに = のまま
#		→ eqnの中の 981101 周辺が怪しいがわからないので debug_eqn などで修正, 981205c
#	●because.sty を直接 tex file に書くことにした → 981205d
#
#txt2tex.pl 0.12, 981125
#	●/*next*/がtexに残る bug, 981125
#	146146/*next*/% txt2tex Warning(1): 右カッコが多いかも？( or [ =0, ) or ] =1146/*next*/% txt2tex Warning(1): 左カッコが多いかも？( or [ =1, ) or ] =0
#		↓
#	% txt2tex Warning(1): 右カッコが多いかも？( or [ =0, ) or ] =1% txt2tex Warning(1): 左カッコが多いかも？( or [ =1, ) or ] =0
#
#txt2tex.pl 0.11, 981123
#	●ignor処理の入れ子ができるようにする, 981123a
#			"Title is ”iMac”."
#		→	Title is "iMac".
#	●半角カナを全角カナに変換する, 981123b → mklinuxの jvim で save すると半角カナが壊れるのでとりあえずif(0)した→hankaku011.plからコピーしなおすと使える

#	●全角英数字を半角英数字に変換する(&ZenA_Z0_9toHan追加), 981123c
#	●&eqnのデバッグ... 	&& 105Ｃ+(w2-e2)^2 q2] → 	105Ｃ&& +(w2-e2)^2 q2] になおす, 981123d
#
#txt2tex.pl 0.10, 981122
#	●txt2tex.pl v0.07 と txt2tex.lib v0.08 を１つにまとめて txt2tex.pl v0.10 にした
#
#txt2tex.pl 0.07, 981119b
#	●981119bを変更(デバッグした)
#	●txt2tex.libとバージョン番号を合わせることにした(0.06.plは欠番)
#txt2tex.pl 0.04, 981119
#	●V^* が V^ になる → s/\*//g;の前に^*,_*の*を\astに変換する → V^{**}ではダメ

#txt2tex.pl 0.03, 981118
#	●箇条書だけで文書がおわるときspace１つの行が必要 → txt2tex.plを修正して自動的に文書末に" \n"を加えるようにした
#txt2tex.pl 0.02, 981101
#	●\begin{thebibliography}{99}のあとに, \end{thebibliography}がない
#		→最後に空行が必要(参考文献の終りが分からないので), 981101
#	txt2tex.pl 0.01, 981004
#Mathematica風のみやすいテキストを latex に変換
#	txt2tex 0.0, 980815
#
#
#txt2tex.lib 0.08 (007.pl), 981121
#	●式ラベル（eq:kijutu6）が\label{eq &:& kijutu6}になる, 981121a
#	●式ラベル（eq:kijutu9）が（{e_{q}}   &:& {k_{ijutu9}}）とラベルにならない, 981121b
#	●TableをT_{able}にしないようにすべき → 981119cに追加
#	●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ → Warningする, 981121d
#	●	　"i)"箇条書 → この行が削除される, 981121e
#
#txt2tex.lib 0.07,
#	●981119bを変更(デバッグした)
#	●かっこのWarningの表示を変更
#	元: % txt2tex Warning(74): ( or [ =1, ) or ] =0
#	新: % txt2tex Warning(74): 左カッコが多いかも？( or [ =1, ) or ] =0
#
#txt2tex.lib 0.06, 981119
#	●V^* が V^ になる → s/\*//g;の前に^*,_*の*を\astに変換する → V^{**}ではダメ

#	●aあああi)縲彿v) → $\left. \left. a$あああ $i\right)\sim {i_{v}}\right)$
#	  括弧の対応が１行単位なので$...$の中で括弧の対応がとれない ex. $\left($...$\right)$
#		→ &check_kakko_in_dollar追加で対応＋文章ではkakko2texの括弧自動付け処理外す, 981119b
#	●Fig.とfig.とFigureとfigureの下付き処理と$の処理をしない981119c
#	●行列の行番号処理のバグ（その1）： → 981119d
#		vdq = ／vd＼  , vd:d軸電圧
#		      ＼vq／  , vq:q軸電圧
#		↓
#		行列のtexのあとに 14Ｃ が残る

#		, {v_{d}}:d軸電圧   14Ｃ, {v_{q}}:q軸電圧
#	●行列の行番号処理のバグ（その2）： → 981119e
#		=／ x ＼ / a
#		 ＼ y ／
#		↓
#		行列のtexのあとに 98Ｃ が残る

#		{\frac{98Ｃ}{a}}
#	●参考文献が \bibitem{189Ｃ1} となる → 981119f
#	● && が付けられた行をエラー表示すると
#		"% txt2tex Bug:現在の行番号を見失いました"のバグメッセージがでる → 981119g
#	●箇条書きのはじまりが
#		i)aaa
#		ii)bbb
#	のとき
#		i)aaa
#		i)bbb
#	となり箇条書のラベルが崩れる → 981119h
#
#txt2tex.lib 0.05, 981118
#	●箇条書と式があるとき行の順番と箇条書の番号が崩れる → 崩れないようにした
#	ex:
#	　1)箇条書きのとき
#		a = 2
#	　3)箇条書きのとき
#		a = 4
#	　5)箇条書きのとき
#		a = 6
#	が
#		1)箇条書きのとき
#		1)
#			a = 2
#		箇条書きのとき
#		1)
#			a = 4
#		箇条書きのとき
#		1)
#			a = 6
#	になる

#	●箇条書だけで文書がおわるときspace１つの行が必要 → txt2tex.plを修正して自動的に文書末に" \n"を加えるようにした(0.03.pl)
#
#txt2tex.lib 0.04, 981101
#	● < が$の処理にならない → <,>を$の処理に加えた
#	●式ラベルに:も許すべき	（{e_{q}}:{k_{ijutu3}}）→式ラベルに:を加えた
#	●図ラベルにfig:を付け加えていたがややこしいのでやめる( \label{fig:kijutu1}, Fig. \ref{kijutu1})
#
#txt2tex.lib 0.03, 981009
#	increase LaTeXmoji
#txt2tex.lib 0.02, 981005
#	debug tbl
#txt2tex.lib 0.01, 981004
#Mathematica風のみやすいテキストを latex に変換
#	txt2tex 0.0, 980815
#
#	tbl2tex 1.0, 980813
#	表：ひょー
#	__________
#	|   || c |
#	==========
#	| a || d |
#	| b || e |
#	__________
#を LaTeX に変換
#
#	eqn2tex 1.0, 980815
#	Ru=Rv=Rw=Ra
#	    ／b,c＼    ／f＼
#	a = ＼d,e／ x+ | g |	（bbb）
#	               ＼h／
#	    ／b,c＼    ／f＼
#	a = ＼d,e／ x+ | g |	（numEq）
#	               ＼h／
#	 	　	    　
#	Ru=Rv=Rw=Ra		（aaa）
#を LaTeX に変換
#
#	fig2tex 1.0, 980814
#	図：図のタイトル(filename)
#を LaTeX に変換
#
# delif0.pl
# list2tex.pl
# bib2tex.pl
# lab2tex.pl
# getIgnor.pl
# putIgnor.pl
# delCom.pl
#
#●注意：
#・LaTeX処理をしないとき→"\verb| abc |" ... \verbの次の１文字で囲う
#・LaTeX処理をしないとき→\begin{verbatim}\n ...\n \end{verbatim}\n
#PRINT_RIREKI
#}
#####################################################'
#	Step 1, $H_INPUT_FILE → txt2tex0.tmp
#####################################################
sub	txt2tex{	#matomato txt2tex(begin)
	$step_number = 1;
	if($S_JCODE != 1){
		&check_eibun(0);	# 日本語コード取得だけする
	}

	# print $H_INPUT_FILE."\n";
	# print $H_OUTPUT_FILE."\n";

	if(0){	# 入出力ファイル名をここに書く場合

		open(IN,"<txt2tex.dat");
		&open_OUT("txt2tex0.tmp");
	}elsif(0){	# 入出力ファイル名をコマンドで指定する場合 ... >> perl delif0.pl in.c out.c
		open(IN,"<".$ARGV[0]);
		open(OUT,">".$ARGV[1]);
		# print @ARGV;print "\n\n";
		# die;
	}elsif($S_JCODE == 1){
		&open_OUT("txt2tex0.tmp");
		if($H_OS eq "MSWin32"){
			open(SERCH,"<:crlf",encode($H_JCODE2,$H_INPUT_FILE));
		}elsif($H_OS eq "darwin"){
			open(SERCH,"<:crlf",$H_INPUT_FILE);
		}
		while($tmp_s .= <SERCH> and $i++ < 50){
			eof and last;
		}
		close(SERCH);
		$tmp_c = guess_encoding($tmp_s);
		$H_JCODE1 = $tmp_c->name;
		# printf 'Encoding of file %s is %s '."\n", $H_INPUT_FILE, $H_JCODE1;
		if($H_OS eq "MSWin32"){
			open(IN,"<:encoding($H_JCODE1)",encode($H_JCODE2,$H_INPUT_FILE));
		}elsif($H_OS eq "darwin"){
			$/ = "\r\n";
			open(IN,"<:encoding($H_JCODE1)",$H_INPUT_FILE);
		}

		if($S_WARNING){ # まとあと警告を削除 201226
			&del_matoato_warning;
		}
	}else{
		&open_OUT("txt2tex0.tmp");
  		if($H_PERL_VER==1){
			open(IN,"<".$H_INPUT_FILE);		# in the case of jperl5
  		}elsif($H_PERL_VER==2){
			# eval 'open(IN, "<",$H_INPUT_FILE);';	# in the case of perl580
			# binmode IN, ":encoding(cp932)";
			# open(IN,"<".encode('cp932',$H_INPUT_FILE));
			open(IN,"<",encode('cp932',$H_INPUT_FILE)); # 200624
  		}
	}


	if($H_PERL_VER==2){
		#----- for perl580 txtファイルをshiftjis --> utf8, begin -----
		&close_OUT;
		&open_OUT("txt2tex1.tmp");
		while(<IN>){
			chomp;
			# $_ = $_ . "\n"; # WindowsはCRLF、DarwinはLFに変換
			# from_to($_, "shift-jis", "utf8");
			$H_OUT = $_ . "\n";
			&print_OUT_euc;
		}
		close(IN);	&close_OUT;
		$/ = "\n";
		# eval 'use open ":utf8"';
		# eval 'open(IN, "<","txt2tex1.tmp");';
		open(IN,"<:utf8","txt2tex1.tmp"); # 200701
		# binmode IN, ":encoding(cp932)";
		&open_OUT("txt2tex0.tmp");
		#----- for perl580 txtファイルをshiftjis --> utf8, end -----
	}

	#	ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	&initdelComment;
	&init_del_if0;
	&init_sharp_define;	#000506d

	$H_OUT='%***** Created by '.$VER.' ******'."\n";   &print_OUT_euc;

	while(<IN>){
		# &to_euc;	# EUCに変換000723a コメントのみのため削除 200624

		# C言語のコメント /* aaa */ を削除

		&delComment;

		# C言語の#define文の処理
		&sharp_define;	#000506d

		# C言語の #if 0 の内容を削除、#if 1, #else, #endif を削除(print OUTを含む）, 行番号作成
		&del_if0;
	}
	$H_OUT = ($.+1)."Ｃ \n";	&print_OUT_euc;	#最後に空行が必要(参考文献の終りが分からないので), 981101, 箇条書でも必要, 981118

	close(IN);	&close_OUT;





#####################################################
#	Step 2, txt2tex0.tmp → txt2tex1.tmp, 000206a
#####################################################
	$step_number = 2;
	# open(IN,"txt2tex0.tmp");
	open(IN,"<:utf8","txt2tex0.tmp"); # 200624
	&open_OUT("txt2tex1.tmp");

	# ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	&init_verbatim;
	&init_get_BEGINNING;
	$_verbatim='';
	# &init_eqn2tex;	#初期設定(eqn2tex) 000227a

	$f_bigtabular=0;	#110810e
	while(<IN>){
		&sharp_define_next;	# ^#defineのときnextする000506d
		chop;

		if(/^[^\%]*\\usepackage\{bigtabular\}/){	$f_bigtabular=1;}#110810e

		if( &Next_Line ){	next;}	# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）

		&verbatim;	# \begin{verbatim}から\end{verbatim}までの行を"で囲う ... /*1*/にする

		if( $f_verbatim ){	#000606e
			$H_OUT = $_."\n";
			if( $f_beginning==0 ){	# beginning処理済み
				&print_OUT_euc;
			}else{					# beginning処理未000813g
				$_verbatim = $_verbatim.$H_OUT;	# <- get_BEGINNINGで出力
			}
			next;
		}

		&verb;		# \verbの次の１文字から、次に現れるまで"で囲う ... /*1*/にする

		if( $f_verb ){	next;}

		#------ 開始処理 ---------
		if( &check_f_beginning ){
			&get_BEGINNING;		if( &check_f_beginning ){	next;}
		}else{	# 000430b
			&debug000430b;
		}

		&ignor_percent;	# %... を /*1*/ にする 000210b

		# ●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a
		# &eqnMatCheckAndModify;

		$H_OUT = $_."\n";	&print_OUT_euc;
	}
	if( &check_f_beginning ){	&get_BEGINNING2;}	# 000309c
	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex0.tmp|');	close(TMP);}	#000801i



#####################################################
#	Step 2.5, txt2tex1.tmp → txt2tex2.tmp
#####################################################
	$step_number = 2.5;
	#require	"txt2tex.lib";
	# open(IN,"<txt2tex1.tmp");
	open(IN,"<:utf8","txt2tex1.tmp"); # 200624
	&open_OUT("txt2tex2.tmp");
	#binmode IN, ":encoding(cp932)";


	#	ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	&init_tbl;	#初期設定(tbl2tex)
	&init_eqn2tex;	#初期設定(eqn2tex)
	&init_fig2tex;	#初期設定(fig2tex)
	&init_subfig;	#初期設定(subfig2tex) # 200624
	&initList2tex;
	&initBib;
	&initLabel2tex;

	while(<IN>){
		&sharp_define_eibun;
		&sharp_define_next;	# ^#defineのときnextする000506d
		# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）
		if( &Next_Line ){
			next;
		}
		s/([^\\])\$\$/$1 /g;			#000707v
		s/([^\\])\$([ 	]+)\$/$1$2/g;	#000707v

		# ● max_{x1} を \max\limits_{x_1} に変換する(min, limも), 000213h,000625g
		$tmp = "lim|max|min";
		s/([^a-zA-Z\\])($tmp)[ 	]*\_/$1\\$2\\limits\_/g;
		s/^($tmp)[ 	]*\_/\\$1\\limits\_/g;
		s/(\\$tmp)[ 	]*\_/$1\\limits\_/g;
		s/\"[ 	]*($tmp)[ 	]*\"[ 	]*\_/\\$1\\limits\_/g;
		s/\"[ 	]*(\\$tmp)[ 	]*\"[ 	]*\_/$1\\limits\_/g;
		# ●Fig.4 → Fig. 4 (Figs.も), Table1 → Table 1, 000213i"
		$tmp = "Fig\.|Figs\.|Table|Figure|Figures";
		s/([^a-zA-Z\\])($tmp)[ 	]*（/$1$2\\ （/g;
		s/^($tmp)[ 	]*（/$1\\ （/g;
		s/(\"[ 	]*)($tmp)([ 	]*\")[ 	]*（/$1$2$3\\ （/g;
		# ●Figs. 3,4 → Figs. 3, 4, 000213j"
		s/）,（/）,\\ （/g;


		&debug981215b;	#	●"\t表目次：" を式にしてしまう。 → タブを削除, 981215b

		&dollarCheck;	# 1行の $ の数が奇数のとき Warning を出す

		s/\/[ 	　]*([\(\{\[（｛［])([\+\-±＋－])/\/$1"$2"/g;	# k1/(-ai +a1) も処理できるようにする110810d

		#------ tbl2tex の処理 ---------
		&tbl;

		# 改行のみの行を削除

		# &omitOnlyKaigyou;
		if( $_ eq "\n" ){
			&bib2tex;	#最後に空行が必要(参考文献の終りが分からないので), 981101
			# &list2tex;	#最後に空行が必要(箇条書の終りが分からないので), 981118
			$H_OUT=$_;	&print_OUT_euc;
			next;
		}

		# 箇条書きをTeXに変換
		&list2tex;

		&getIgnor;

		s/([\(\[｛])([^ 	][^\(\[｛｝\]\)]*\/)/$1 $2/g;	#000530g
		s/(\/[^\(\[｛｝\]\)]*[^ 	])([\)\]｝])/$1 $2/g;	#000530g

		$H_OUT=$_;	&print_OUT_euc;
	}
	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex1.tmp|');	close(TMP);}	#000801i
#####################################################
#	Step 2.7, txt2tex2.tmp → txt2tex2a.tmp
#####################################################
	$step_number = 2.7;
	# open(IN,"<txt2tex2.tmp");
	open(IN,"<:utf8","txt2tex2.tmp"); # 200624
	&open_OUT("txt2tex2a.tmp");
	while(<IN>){
		&sharp_define_eibun;
		&sharp_define_next;	# ^#defineのときnextする000506d
		# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）
		if( &Next_Line ){
			next;
		}

		#------ eqn2tex の処理 ---------
		&eqn;
		# if(!/^	　/){	&eqn;}#110808a

		# 箇条書きをTeXに変換
		# &list2tex;#110808a

		#------ fig2tex の処理 ---------
		&figure;

		#------ subfig2texの処理 -------
		&subfig; # 200603

		#参考文献をTeXに変換
		&bib2tex;

		#章，節，節節，付録のラベルを抽出，作成
		&get_label_section;


		$H_OUT=$_;	&print_OUT_euc;
	}

	# 式，図，表，箇条書き，参考文献の参照ラベルのファイルへの出力（あとで参照処理で使う）
	&writeLabel;

	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex2.tmp|');	close(TMP);}	#000801i

	# Write bibliography in the txt file to bib file.
	# &writeBib; # txtからbibへ書き込むことがないこと、想定してない挙動を確認したため削除 201227

#####################################################
#	Step 3, txt2tex2a.tmp → txt2tex3.tmp
#####################################################
	$step_number = 3;
	#require	"txt2tex.lib";	#981122
	# open(IN,"<txt2tex2a.tmp");
	open(IN,"<:utf8","txt2tex2a.tmp"); # 200624
	&open_OUT("txt2tex3.tmp");
	#binmode IN, ":encoding(cp932)";


	#	ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	$f_eqnarray = 0;	$f_debug000212h = 0;	$f_array = 0;

	# 図，表，式，箇条書き，参考文献の参照ラベルの一覧ファイルの読込
	&readLabel;

	while(<IN>){
		&sharp_define_next;	# ^#defineのときnextする000506d
		# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）, 上に移動した000430d
		if( &Next_Line ){
			next;
		}

		# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換える, 上に移動した000430d
		&getIgnor;
		&ignor_mbox;	#	◯txt2tex:debug: \mbox{...}を ignor化, 000625n,場所移動000801k

		# 図，表，式，箇条書き，参考文献の参照ラベルを TeX に変換してダブルクォーテーション"で囲む

		if( /（/ && /）/ ){ # わかりにくい200601
			# if( !(/^	図：/) && !(/^	表：/)  ){
				&label2tex;
				&getIgnor;	# 000430d
			# }
		}

		# ●&eqnのデバッグ... 	&& 105Ｃ+(w2-e2)^2 q2] → 	105Ｃ&& +(w2-e2)^2 q2] になおす, 981123d
		# s/^	\&\& ($H_LineNum)/	$1\&\& /;	# $H_HeaderFile は txt2tex.lib package の中だけでしか使えない
		s/^	\&\& ([0-9][0-9]*Ｃ)/	$1\&\& /;

		$H_OUT=$_;	&print_OUT_euc;
	}

	# ダブルクォーテーション"で囲まれた文字列をignor.datに書く
	&writeIgnor;

	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex2a.tmp|');	close(TMP);}	#000801i



#####################################################
#	Step 4, txt2tex3.tmp → txt2tex4.tmp
#####################################################
	$step_number = 4;
	#require	"txt2tex.lib";	#981122
	# open(IN,"<txt2tex3.tmp");
	open(IN,"<:utf8","txt2tex3.tmp"); # 200624
	&open_OUT("txt2tex4.tmp");
	#binmode IN, ":encoding(cp932)";


	#	ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	&define_LaTeXmoji;	#simotuki, frac
	&init_kakko2tex;
	$f_eqnarray = 0;	$f_debug000212h = 0;	$f_array = 0;


	while(<IN>){
		# $_='5/6	u_a 1/2'."\n";
		# $_='5/6	φfu(θ)= φfu_ave(1 + Lu_amp/Lu_ave Cos[2 θ])'."\n";
		# $_='(a*b/(a×x)＊b)/(c+d) (a-b)/(c+d*e)	 a/(c+d)	a/bbb'."\n";
		# $_=' a/b/c a / b-ab / bc+abc / bcd*ab/bc/2* ( a + b ) / (b+c)'."\n";
		# $_='	   = iu if d/dθ{√  	a {La Lf} Cos[θ]}'."\n";
		# $_='	\caption{３相モータ}'."\n";
		# $_='	{v_{u}}	&:& u相電圧'."\n";

		if( /\\begin[ 	]*\{[ 	]*eqnarray[ 	]*\}/ ){	$f_eqnarray=1;}	#000506e
		if( /\\end[ 	]*\{[ 	]*eqnarray[ 	]*\}/ ){	$f_eqnarray=0;}

		# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）
		if( &Next_Line ){
			&check_kakko2tex;
			next;
		}

		&sharp_define_eibun;	#000506e
		&sharp_define_next;	# ^#defineのときnextする000506d

		#------ 空行に % を付ける 000211a ---------
		&rm_kuugyou;
		if( !(&sharp_define_eibun_chk) || $f_eqnarray==1 ){	#000506e
			#------ ignor /*1*/ を，行にない数字 1 に置き換える処理 ---------
			&replIgnor;

			#------ * をスペースに変換する処理(begin) ---------
			s/([\^|\_])[ 	]*([\{]*)[ 	]*\*/$1$2\\ast /g;	# 981119 → V^{**}ではダメ

			s/\*/ /g;

			#------ √{a b}を{√{a b}}と中かっこで囲む処理(begin) ---------
			&root;

			#------ (a+b)/(c+d)をfrac{a+b}{c+d}にする処理(begin) ---------
			&frac;

			#------ ignor /*1*/ を，行にない数字 1 に置き換える処理を元に戻す処理
			&unreplIgnor;

			&LaTeXmoji2;
			#------ 下付き Tave → T_{ave} にする処理(begin) ---------
			&simotuki;

			#------ ＾a, ~b, ￣ {c+d} を {＾a}, {~b}, {￣{c+d}}にする

			#------ ＾~￣α → ＾{~{￣α}}}
			while( s/([＾\~￣])[ 	]*(\{+)/$2$1/g ){}	# ￣yp → {￣{y_p}} → {￣y_p}
			&tilde_tyuukakko;	# 000426a, 000430f

			#------	かっこ ( → \left(，）→ \right), kakko2tex
			if( /^	/ ){	# 981119b
				&kakko2tex;
			}

			#------ 全角文字のLaTeX文字への置換えの処理(begin) ---------
			&LaTeXmoji;

			#------ 式の行を読み飛ばす処理 ---------
			&nextIFtab;	#\begin{eqnarray} ... の中だけ ^\t となっている


			#------ 段落の空行を改行にする処理 ---------
			&getKaigyou;

			#------ 文章の中の式の両サイドに$を挿入にする処理 ---------
			&dollar2;	# 000210f
			# s/\$([ 	\,]*)\\(LaTeX|TeX)([ 	\,])*\$/$1\\$2$3/g;	#000601c
			s/\$([ 	\,]*)\\(LaTeX2e|LaTeX|TeX)[ 	]*\$[ 	]*/$1\\$2 /g;	#000601c,000611a
			s/\$([ 	\,]*)\\(LaTeX2e|LaTeX|TeX)[ 	]*([\,])*\$[ 	]*/$1\\$2 $3 /g;	#000611a

			#------ $, $を, にする処理 ---------
			&dollar_ignor;

			#	●\tilde, \hat, \barが$\tilde$になることがある。(引数なしのlatex error)→ $\tilde{}$とする, 000212g
			s/\\(tilde|hat|overline)[ 	]*\$/\\$1\{\}\$/g;#110817a
		}else{
			&get_LineNum;
			chop;	$i000506e=1;	$_new000506e='';
			&getKaigyou;
			while( s/\/\*([0-9]*)\*\/(.*)// ){	# ignorしていた $ を元に戻す, 000707s
				if( $ptnIgnor[$1] eq '$' ){
					$_new000506e=$_new000506e.$_.'$';
				}else{
					$_new000506e=$_new000506e.$_."/\*".$1."\*\/";
				}
				$_=$2;
			}
			$_=$_new000506e.$_;	$_new000506e='';

			while( s/(.*)\$// ){
				$_tmp000506e=$1;
				if( $i000506e==0 ){	$i000506e=1;}else{	$i000506e=0;}
				$_=$_."\n";
				if( $i000506e==1 ){
					&replIgnor;
					s/([\^|\_])[ 	]*([\{]*)[ 	]*\*/$1$2\\ast /g;	# 981119 → V^{**}ではダメ

					s/\*/ /g;
					&root;
					&frac;
					&unreplIgnor;
					&LaTeXmoji2;
					$_=$_."\n";&simotuki;chop;
					while( s/([＾\~￣])[ 	]*(\{+)/$2$1/g ){}	# ￣yp → {￣{y_p}} → {￣y_p}
					&tilde_tyuukakko;
					# if( /^	/ ){	# 981119b
					# &kakko2tex;
					# }
					&LaTeXmoji;
					# &nextIFtab; #??
					# &dollar2;	# 000210f
					# &dollar_ignor;
				}else{
					&LaTeXmoji_with_dollar;	&dollar_ignor;
				}
				chop;
				$_new000506e = '$'.$_.$_new000506e;	$_=$_tmp000506e;
			}
			$_=$_."\n";
			&LaTeXmoji_with_dollar;	&dollar_ignor;
			chop;
			$_ = $_.$_new000506e."\n";
		}

		$H_OUT=$_;	&print_OUT_euc;
	}

	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex3.tmp|');	close(TMP);}	#000801i




#####################################################
#	Step 4.5, txt2tex4.tmp → txt2tex5.tex
#####################################################
	$step_number = 4.5;
	# open(IN,"<txt2tex4.tmp");
	open(IN,"<:utf8","txt2tex4.tmp"); # 200624
	&open_OUT("txt2tex5.tmp");

	#	ヘッダファイル（defineなど）
	&HeaderFile;

	#----- 初期設定　----
	&init_youyaku;	#初期設定(要約)
	&init_section;
	$f_verbatim = 0;	# 981205c
	$_verbatim = '';	# 981205c
	&init_tbl;	#初期設定(tbl2tex)	#000212d
	$f_eqnarray = 0;	# 000213d
	&init_debug_eqn;



	#------ ラベル作成など ---------
	while(<IN>){
		&rm_sharp_define;	# ^#defineの行を削除する000605a

		if( !(/\/\*next\*\//) ){
			s/\, /\,\\ /g;	# 000502b
	
			chop;
			while( s/(\\overline|\\hat)[ 	]*(\\overline|\\hat)([ 	]*[\\a-zA-Z0-9]*)/$1 \{$2$3\}/ ){}	# 000403c,000707q,110817a
			while( s/\{\\overline /\\overline \{/ ){}	# 110823a
			$_=$_."\n";	#000707q

			s/”/\"/g;	#000502c
			while( s/\$[ 	]*([\(\)\{\}\[\]])[ 	]*\$/$1/g ){}	#000502d

			s/｛/\\{/g;	# 000530f
			s/｝/\\}/g;	# 000530f

			while( s/([^\\])\#/$1\\\#/g ){}	s/^\#/\\\#/;	#000530h
		}

		#------ txt2tex Warning行の処理 ---------
		if( &print_OUT_warning ){	next;}

		if( !(/^$H_nextComp\%/) ){	# 981119b, 981121a, 981205c, 000227b
			&debug_eqn;
		}

		&section;	# 章，節，節節の処理,000206

		# 行番号を削除LineNum, 981205c
		&rm_LineNum;
		if(/[0-9][ 	\$]*Ｃ/){&print_("txt2texのバグ？ Ｃが残ってて変かも？xxx");&print_($_);}

		# ●全角英数字を半角英数字に変換する(&ZenA_Z0_9toHan追加), 981123c
		&ZenA_Z0_9toHan;

		# ●\varphi (s), \maxが$$に入らない：\varphi $\left(s\right)$ → $\varphi \left(s\right)$, 000213d, putIgnorより上に移動000504f
		if( /\\begin\{eqnarray/ ){	$f_eqnarray = 1;}
		if( /\\end\{eqnarray/ ){	$f_eqnarray = 0;}
		if( $f_eqnarray==0 ){	&debug000213d;}
		else{	s/：/\\vdots /g;}#	●式の中の ： → \vdots, 000213f,000530b

		# 参照ラベルとダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換えた文字列を元に戻す。
		&putIgnor;

		#------ 処理済み行の記号削除の処理 ---------
		&omitNext;

		# while(s/\\left(.[a-zA-Z0-9\-\+\*\/ 	]*)\\right(.)/$1$2/){;}	#030918
		if(/^ $/){	next;}	# 120216

		$H_OUT=$_;	&print_OUT;	#000206
	}



	#------ 終了処理 ---------
	&getENDING;

	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex4.tmp|');	close(TMP);}	#000801i
	if($H_DEBUG==0 || $H_DEBUG1==0){	open(TMP,$H_RM.' ignor.dat|');	close(TMP);}	#000801i
	if($H_DEBUG==0 || $H_DEBUG1==0){	open(TMP,$H_RM.' label.dat|');	close(TMP);}	#000801i


#####################################################
#	Step 5, txt2tex5.tmp → H_OUTPUT_FILE
#####################################################
	$step_number = 5;
	# open(IN,"<txt2tex5.tmp");
	open(IN,"<:utf8","txt2tex5.tmp"); # 200624
	# open(OUT,">".encode('cp932',$H_OUTPUT_FILE));
	# open(OUT,">",encode('cp932',$H_OUTPUT_FILE)); #200624
	&open_OUT($H_OUTPUT_FILE);

	#------ txt2tex5.tmpでtexファイル作成完了。Step 5はそのデバッグ用 ---------110808a
	$f110808a=0;
	$f110808a2=0;
	while(<IN>){
  	if(0){
		chop;
		if($f110808a==2){
			if(    $_ eq "\\begin{enumerate}" ){				$f110808a=3;}
			# elsif( /^	\\renewcommand{\\labelenumi}{/ ){	$f110808a=3;}
			elsif( /^	\\renewcommand\{\\labelenumi\}\{/ ){	$f110808a=3;} # 200624 perl5.26から必要？
			elsif(    $_ eq "\\end{enumerate}" ){					$f110808a=3;}
			elsif( $_ eq "" || $_ eq "%" ){	print OUT "\\end{enumerate}\n";	$f110808a=0;}
			# elsif( /^\\[abc]*section{/ || /^\\end{document}/ ){
			elsif( /^\\[abc]*section\{/ || /^\\end\{document\}/ ){ # 200624
				print OUT "\\end{enumerate}% txt2tex Warning 箇条書きの処理に失敗しました。(110808a)\n";	$f110808a=0;
				print "txt2tex Warning 箇条書きの処理に失敗しました。(110808a)\n";
			}
		}
		if($f110808a==1){
			if($_ eq "\\begin{eqnarray}" ){			$f110808a=2;}
			else{	print OUT "\\end{enumerate}\n";	$f110808a=0;}
		}
		if($f110808a==0 && $_ eq "\\end{enumerate}" ){	$f110808a=1;}


		if($f110808a2==2){	if($_ eq '\end{eqnarray}'){	print OUT "\\end{eqnarray}\n	\item\n";	$f110808a2=3;}}
		if($f110808a2==1){	if($_ eq '\begin{eqnarray}'){	$f110808a2=2;}}
		if($_ eq '	\item'){	$f110808a2=1;}


		if( $f110808a==3 ){	$f110808a=2;}	# 3のとき$_を書かない
		elsif( $f110808a!=1 && $f110808a2!=1 && $f110808a2!=3 ){	print OUT $_."\n";}
		if( $f110808a2==3 ){$f110808a2=0;}
  		}else{
			print OUT $_;
  		}
	}
	if($f110808a==2){print OUT "\\end{enumerate}% txt2tex Warning 箇条書きの処理に失敗しました。(110808a)\n";}

	close(IN);	&close_OUT;
	if($H_DEBUG==0){	open(TMP,$H_RM.' txt2tex5.tmp|');	close(TMP);}

	if($S_WARNING){&insrt_matoato_warning_body;} # warning文の出力 201226

}	#matomato txt2tex(end)


#####################################################
#	以降はサブルーチン群（元txt2tex.lib）
#####################################################

#package	txt2tex;


#------------------------------------
#	汎用のサブルーチン (begin)
#------------------------------------
#	ヘッダファイル（defineなど）
#&HeaderFile;
sub	HeaderFile{
	$H_next = '/*next*/';
	$H_nextComp = '\/\*next\*\/';
	# $H_next = '^!#next#!';

	# 行番号を元に戻すLineNum, 980925
	$H_LineNum = '[0-9][0-9]*Ｃ';
	# $H_LineNum = '';#line off

	# 箇条書きの設定(List2tex)
	#  0:参照ラベルなし、1:A1などのみ参照ラベルあり(default)、2:1とA1に参照ラベルつける

	$modeItem = 1;
}

# open(OUT,">file.out");パッケージで OUT が使えるようにした
sub	open_OUT{
	local($nameOUT) = @_;
	# open(OUT,">".$nameOUT);
	# open(OUT,">",$nameOUT); # 200624
	if($H_OS eq "MSWin32"){
		open(OUT,">:utf8",encode($H_JCODE2,$nameOUT));
	}elsif($H_OS eq "darwin"){
		open(OUT,">:utf8",$nameOUT); # 200901
	}
	# binmode OUT, ":encoding(cp932)";
}

# close(OUT);パッケージで OUT が使えるようにした
sub	close_OUT{
	close(OUT);
}

# /*next*/のときの処理（処理終了行を処理せずつぎの行を読む）
#	if( &Next_Line ){
#		next;
#	}
sub	Next_Line{
	if( /^$H_nextComp/ ){
		$H_OUT=$_;	&print_OUT_euc;
		return 1;
	}else{
		return 0;
	}
}

#------ 処理済み行の記号削除の処理 ---------
sub	omitNext{
	if( s/^$H_nextComp// ){	return(1);}
	else{					return(0);}
}

#------ 行の文字をさかさまにする ---------
sub	inverse{
	# chop;#980922
	s/\n//;		# avoid 無限loop, 980925
	$subtmp_new = '';
	while(length($_)>0){
		s/.$//;
		$subtmp_new = $subtmp_new.$&;
	}
	$_ = $subtmp_new;#980922."\n";
}

#------ LaTeX 記号、文字の定義(begin) ---------
#&define_LaTeXmoji;
#	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
#		s/$def_txt_hensuu[$i]/$def_tex_hensuu[$i] /g;
#	}
#
sub	define_LaTeXmoji{
	my	($tmp_, $tmp2_, $x, $i);
	#----- 変数に使う文字(begin) ----
		#		sub simotuki, sub frac で使われる

		#	Ο	O
		#	Π	\Pi
		#	ε	\epsilon
		#	θ	\vartheta
		#	ο	o
		#	π	\varpi
		#	σ	\varsigma
		#	φ	\varphi
$x='
	Γ	\Gamma
	Δ	\Delta
	Θ	\Theta
	Λ	\Lambda
	Ξ	\Xi
	Π	\prod
	Σ	\Sigma
	Υ	\Upsilon
	Φ	\Phi
	Ψ	\Psi
	Ω	\Omega
	α	\alpha
	β	\beta
	γ	\gamma
	δ	\delta
	ε	\varepsilon
	ζ	\zeta
	η	\eta
	θ	\theta
	ι	\iota
	κ	\kappa
	λ	\lambda
	μ	\mu
	ν	\nu
	ξ	\xi
	ρ	\rho
	σ	\sigma
	τ	\tau
	υ	\upsilon
	φ	\phi
	χ	\chi
	ψ	\psi
	ω	\omega
	π	\pi
	∞	\infty
';
	#----- 変数に使う文字(end) ----

	$tmp_ = $_;
	$_ = $x;
	$i = 0;
	while(length($_)>0){
		s/^(.*)\n//;
		$tmp2_ = $_;	$_ = $&;
		if( /[ 	　]*(.)[ 	　]*(\\[a-zA-Z]+)/ ){
			$def_txt_hensuu[$i] = $1;
			$def_tex_hensuu[$i] = $2;	$i++;
		}
		$_ = $tmp2_;
	}
	$_ = $tmp_;
	# print @def_txt_hensuu;print "X\n";
	# print @def_tex_hensuu;print "X\n";

	#----- 変数以外に使う文字(begin) ----
		# 注意：
		#	√	\sqrt/g;	# dos
		#	√	\sqrt/g;	# mac(osaka)
		#	⊆の否定	\nsubseteq
		# 入れてない：
		#	⊇	\nsupseteq
		#	∈の否定	\notin
		#	←	\Leftarrow
		#	→	\Rightarrow
		#	↑	\Uparrow
		#	↓	\Downarrow
		#	∃の小文字みたいなの	\SuchThat
		#	\\（バックスラッシュみたいなの）	\setminus
		#	π	\varpi
		#	：	\vdots	# 題名：なども変換する, 981209c, 981219a, 981219b
		#	●全角のローマ数字を LaTeXmoji に変換する, 000309b
		#		・小文字  → {\romannumeral 2} # 文字化けしてたので消した 200624
		#		・大文字 Ⅵ → {\expandafter\uppercase\expandafter{\romannumeral 6}}
		#	Ｕ	\bigcup	#000801q
		#	ｕ	\cup	#000801q
		#	Ｖ	\bigvee	#000801q
		#	ｖ	\vee	#000801q
		#	ｏ	\circ	#000801q
		#	ｌ	\ell	#000801q
		#	Ｒ	\Re		#000801q
		#	Ｉ	\Im		#000801q
		# 200624重複してるやつ消した
$x='
	○	\bigcirc
	△	\bigtriangleup
	▽	\bigtriangledown
	☆	\star
	◯	\bigcirc
	〇	\bigcirc
	《	\ll
	》	\gg
	←	\leftarrow
	→	\rightarrow
	↑	\uparrow
	↓	\downarrow
	⇒	\Rightarrow
	⇔	\Leftrightarrow
	…	\cdots
	‥	\cdots
	⇒	\Rightarrow
	⇔	\Leftrightarrow
	￡	\pounds
	Å	\AA
	±	\pm
	×	\times
	÷	\div
	≒	\simeq
	≠	\neq
	≦	\leq
	≧	\geq
	≪	\ll
	≫	\gg
	∝	\propto
	∴	\therefore
	∵	\because
	∈	\in
	∋	\ni
	⊆	\subseteq
	⊇	\supseteq
	⊂	\subset
	⊃	\supset
	∪	\bigcup
	∩	\bigcap
	∧	\bigwedge
	∨	\bigvee
	￢	\neg
	⇒	\Rightarrow
	⇔	\Leftrightarrow
	∀	\forall
	∃	\exists
	∠	\angle
	⊥	\top
	⌒	\frown
	≡	\equiv
	Ё	\mbox{\"{E}}
	П	\prod
	Ц	\coprod
	Э	\ni
	ё	\mbox{\"{e}}
	о	\circ
	п	\sqcap
	ц	\sqcup
	э	\ni
	┐	\neg
	├	\vdash
	┤	\dashv
	│	\mid
	┝	\models
	┴	\perp
	＃	\sharp	
	＊	\ast
	§	\S
	♯	\sharp
	♭	\flat
	†	\dag
	‡	\ddag
	¶	\P
	～	\sim
	＊	\ast
	・	\cdot
	＾	\hat
	~	\tilde
	￣	\overline
	∂	\partial
	∇	\nabla
	√	\sqrt
	∬	\int \int
	∫	\int
	Ⅰ	{\expandafter\uppercase\expandafter{\romannumeral 1}}
	Ⅱ	{\expandafter\uppercase\expandafter{\romannumeral 2}}
	Ⅲ	{\expandafter\uppercase\expandafter{\romannumeral 3}}
	Ⅳ	{\expandafter\uppercase\expandafter{\romannumeral 4}}
	Ⅴ	{\expandafter\uppercase\expandafter{\romannumeral 5}}
	Ⅵ	{\expandafter\uppercase\expandafter{\romannumeral 6}}
	Ⅶ	{\expandafter\uppercase\expandafter{\romannumeral 7}}
	Ⅷ	{\expandafter\uppercase\expandafter{\romannumeral 8}}
	Ⅸ	{\expandafter\uppercase\expandafter{\romannumeral 9}}
	Ⅹ	{\expandafter\uppercase\expandafter{\romannumeral 10}}
	≡	\equiv
	∑	\sum
	∫	\int
	∮	\oint
	√	\sqrt
	⊥	\top
	∠	\angle
';
	#----- 変数以外に使う文字(end) ----

	$tmp_ = $_;
	$_ = $x;
	$i = 0;
	while(length($_)>0){
		s/^(.*)\n//;
		$tmp2_ = $_;	$_ = $&;
		# if( /[ 	　]*(.)[ 	　]*(\\[a-zA-Z]+)/ ){
		if( /[ 	　]*(.)[ 	　]*(.*)[ 	　]*/ ){	#000309b
			$def_txt_moji[$i] = $1;
			$def_tex_moji[$i] = $2;
			$i++;
		}
		$_ = $tmp2_;
	}
	$_ = $tmp_;
	# print @def_txt_moji;print "X\n";
	# print @def_tex_moji;print "X\n";


	# used in frac and simotuki
	$def_txt_hensuuAll = '';
	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
		$def_txt_hensuuAll .= $def_txt_hensuu[$i]; # $def_txt_hensuuAll = $def_txt_hensuuAll . $def_txt_hensuu[$i]
	}
	$fNoFrac = 0;	# 981119e 1/3
}
#------ LaTeX 記号、文字の定義(end) ---------

# 現在の行番号を調べる, (begin) 981004
sub	getLineNum{
	if( /^[ 	　／\|＼]*([0-9][0-9]*)Ｃ/o ){
		$LineNum = $1;
	}elsif( /^	\&\& ([0-9][0-9]*)Ｃ/o ){
		$LineNum = $1;						# 981119g
	}elsif( /^$H_next/o || /[^ 	　／\|＼]*$/o ){ # ($H_next)にしないといけない？
		$LineNum = '';
	}else{
		$LineNum = '';
		if( length($_)>0 ){	# 981119b
			$H_OUT = '% txt2tex Bug: 現在の行番号を見失いました'.$_."\n";
			&print_($H_OUT);	$H_OUT=$H_next.$H_OUT;	&print_OUT_euc;
		}
	}
}
sub	get_LineNum{
	&getLineNum;
}
# 現在の行番号を調べる, (end)

#------------------------------------
#	汎用のサブルーチン (end)
#------------------------------------


sub	ignor_percent{	# %... を /*1*/ にする 000210b
	# if( s/^(	[ 	　]*)($H_LineNum)([図表]：[^\%]*)[ 	　]*(\%.*)$/$1$2$3/ ){	#000505c
	if( s/^(	[ 	　]*)($H_LineNum)([図表縦横]：[^\%]*)[ 	　]*(\%.*)$/$1$2$3/ ){	# 200624
		$H_OUT='/*'.$nIgnor.'*/'."\n";	&print_OUT_euc;	$ptnIgnor[$nIgnor] = $4;	$nIgnor++;
	}elsif( s/(\%.*)$// ){
		$_ = $_.'/*'.$nIgnor.'*/';	$ptnIgnor[$nIgnor] = $&;	$nIgnor++;
	}
}

#------------------------------------
#	タイトル等の開始処理(begin)
#------------------------------------
#初期設定(要約)
sub	init_youyaku{
	$fYouyaku = 0;
}

#	------ TeXのはじまりの書き方 ----------
#1. 題名，著者，アブストラクトを書く
#2. \begin{document} を書く
#3. \maketitleまたは目次などを書く（順番は保持される）
#		\maketitleは題名，著者，アブストラクトを表示する


#------ 題名、著者、要約の処理(begin) ---------
#
#\documentstyle[epsbox]{jarticle}
#%\setlength{\topmargin}{5mm}
#%\setlength{\headheight}{50mm}
#\setlength{\textwidth}{140mm}
#%\pagestyle{myheadings}
#
#\title{低速域平均速度ふらつきに関する一考察}
#\author{木村}
#
#\begin{document}
#
#\maketitle
#\begin{abstract}
#あああ
#\end{abstract}
#\date{\today}
#
#初期設定 000206
#sub init_get_BEGINNING0{
#	$f_beginning = 1;
##\documentstyle[psbox,because]{jarticle}
#	$title='';	$f_title = 0;
#	$author='';	$f_author = 0;
##\begin{document}
#			$f_maketitle = 0;
#			$f_mokuji = '';
##
#	$abstract='';	$f_abstract = 0;	$fmem_abstract = 0;
#	$after_abstract = '';	# 000201c
#	$date='';	$f_date = 0;
##
##
##	$bib='';	$f_bib = 0;
##\end{document}
#}
#	●&sectionの全面改訂 ... 題名などはじまりの処理を完全に書き直して、この処理を &get_BEGINNING に融合, 000206a
#	&get_BEGINNING の仕様
#		1.\documentstyle[psbox,because]{jarticle} を書く
#		2.\def\thereforeと\def\becauseを書く
#		3.\setlength{\headheight}などを書く
#		4.題名：リング	→　\title{リング}に変換
#		5.作成：くま	→　\author{くま}に変換
#		6.\begin{document}を書く
#		7.目次：，表目次：，図目次	→　\tableofcontents，\listoftable，\listoffiguresに変換
#		8.要約：これこれ	→　\begin{abstract}これこれ\end{abstract}に変換
#		9.日付：いついつ	→　\date{いついつ}に変換
#		・題名：，作成：，要約：，日付：のいずれかがあるとき\maketitleを書く。
#			→　作成：なしで\maketitleを書くとき\author{}を書く（ないとlatex error）
#		・'○○：'の順番がlatex error を引き起こすときだけ順序を入れ換える。あとは"\etitle{...}"などをそのまま出力
#			確認したlatex errorは以下の通り。
#				・\？？？のあとに\？？？がくるとき。
#		・beginning処理の終了条件は、'章：' or 空行の次の行が\aaa以外 or １行目から'題名：'や\aaaや空行など以外のとき
#		・'○○：'の終わりの条件は、空行または'○○：'の行のとき。
#		・\documentstyleや'○○：'が２重に定義されているとき、後の定義を優先し、warningを出して前のを無視する。
#		　　→　\verbや\begin{verb}の中身を無視する。
#	&get_BEGINNING  ... ○○：の変換のみ
#	&get_BEGINNING2 ... \documentstyleなどを書く　＋　２重定義の処理
#	&get_BEGINNING3 ... 順番による latex error を避けるように順序入れ替え　＋　出力
#初期設定

sub init_get_BEGINNING{
	$f_ikinari_honbun = 1;	# いきなり1行目から本文がはじまったフラグ

	$f_beginning = 1;		# beginning処理フラグ

	$_percent = '';			# %以下の文

	$c_documentstyle = 0;	# 出現回数
	$c_usepackage_dvips = 0;# 出現回数020322a

	$c_therefore = 0;		# 出現回数

	$c_because = 0;			# 出現回数

	$c_setlength_topmargin = 0;	# 出現回数

	$c_setlength_headheight = 0;# 出現回数

	$c_setlength_textheight = 0;# 出現回数

	$c_setlength_textwidth = 0;	# 出現回数

	$c_myheadings = 0;		# 出現回数

	$c_begin_document = 0;	# 出現回数

	$c_begin_document0 = 0;	# 出現回数

	$c_maketitle = 0;		# 出現回数


	$c_tableofcontents = 0;	# 目次：の数

	$c_listoftables = 0;	# 表目次：の数

	$c_listoffigures = 0;	# 図目次：の数

	$c_title = 0;			# 題名：の数

	$c_author = 0;			# 作成：の数

	$c_date = 0;			# 日付：の数

	$c_abstract = 0;		# 要約：の数 「要約」と「概要」は同じabstractを表すが、別の処理を行うため注意 200701

	$c_kuugyou = 0;			# 空行の数

	@ptnBeginning = //;	$nBeginning = 0;		# 貯める変数とインデックス
	@ptnBeginning2 = //;	$nBeginning2 = 0;	# 貯める変数2とインデックス2
	$f_finding_migityuukakko = 0;	# 右中カッコ}を書く位置を探し中のフラグ
	$f_finding_end_abstract = 0;	# \end{abstract}を書く位置を探し中のフラグ
	$f_begin_document = 0;	# \begin{document}出力要求フラグ
	$f_begin_document_not_yet = 1;	# \begin{document}出力未フラグ

	# $style_file = "jarticle";	# default style file	#000507a
	$style_file = "jsarticle";	# default style file	# 200624

	$H_a4j = 1;				# a4j.styを使うとき1, 000530i

	$f_papersetting = 0; # 用紙設定用マクロ「papersetting」を見つけるフラグ
	$n_papersetting = 0; # 用紙設定用マクロ「papersetting」の数値

	$c_abstract_new = 0; # 概要の数 200701

	$c_keywords = 0; # 鍵の数 200701

	$c_engtitle = 0; # 英語タイトルの数 200701

	$c_engauthor = 0; # 英語筆者の数 200701

	$C_subfile = 0; # subfilesのカウント 210701
}

sub check_f_beginning{	# main routin で $f を参照しても見れないので、見れるように関数で参照する

	return($f_beginning);
}

sub get_BEGINNING{	#	&get_BEGINNING  ... ○○：の変換のみ, 小修正000427a
	#---- %... があるとき、削除して後でつなぐ
	# if(!/\%.*\\maketitle/){	#030921
	if(!(/\%.*\\maketitle/)){ #  括弧でくくった 200624
		if( s/(\%.*)$// ){	$_percent = $&;}else{	$_percent = '';}
	}
	#---- \documentstyleなどがあるとき、フラグを立てる。
	if( /\\documentstyle[^\{]*\{[ 	]*([^\}]*)[ 	]*\}/ ){
		$c_documentstyle += 1;
		$style_file = $1;		#000507a
	}
	#---- \documentclassがあるとき、変数に入れ、フラグを立てる。
	if( s/\\documentclass([^\{]*)\{[ 	]*([^\}]*)[ 	]*\}//){	#020322a
		$c_documentstyle += 1;
		$documenttmp = $&;
		$option = $1;
		$style_file = $2;
		# if($option =~ /(\d+)pt/){ # これだと10.5ptの時正しい挙動をしない
		if($option =~ /(\d+\.?\d?)pt/){
			$documentpoint = $1/10; # subfigの大きさ調整に使う 200624
		}else{
			$documentpoint = 1;
		}
		if($style_file eq 'subfiles'){ # 210701
			$C_subfile++;
		}
		$ptnBeginning2[$nBeginning2] = '"'.$documenttmp.'"';
		$nBeginning2++;
	}
	#---- \papersetting{?}があるとき、フラグを立てる。 200701
	if(/\\papersetting[ 	]*\{[ 	]*(\d)[ 	]*\}/){
		$n_papersetting = $1;
		if($n_papersetting == 0){
			$f_papersetting = 0;
		}else{
			$f_papersetting = 1;
		}
	}
	#---- \usepackage[dvips]{graphicx}があるとき、フラグを立てる。→ないときあとでつける020322a =>divpsからdvipdfmxに変更 200624
	# if( /\\usepackage[ 	]*\[[ 	]*dvips[ 	]*\][ 	]*\{[ 	]*graphicx[ 	]*\}/ ){
	if( /\\usepackage[ 	]*\[[ 	]*dvipdfmx[ 	]*\][ 	]*\{[ 	]*graphicx[ 	]*\}/ ){ # 200624
		$c_usepackage_dvips += 1;
	}
	if( /\\def[ 	]*\\therefore/ ){				$c_therefore += 1;}
	if( /\\def[ 	]*\\because/ ){					$c_because += 1;}
	if( /\\setlength[ 	]*\{[ 	]*\\topmargin/ ){	$c_setlength_topmargin += 1;}
	if( /\\setlength[ 	]*\{[ 	]*\\headheight/ ){	$c_setlength_headheight += 1;}
	if( /\\setlength[ 	]*\{[ 	]*\\textheight/ ){	$c_setlength_textheight += 1;}
	if( /\\setlength[ 	]*\{[ 	]*\\textwidth/ ){	$c_setlength_textwidth += 1;}
	if( /\\pagestyle/ ){							$c_myheadings += 1;}
	if( /\\begin[ 	]*\{[ 	]*document[ 	]*\}/ ){$c_begin_document += 1;}
	if( /\\maketitle/ ){							$c_maketitle += 1;}

	#---- 題名：などを変換して、フラグを立てる。
	#---- ・'○○：'の順番がlatex error を引き起こすときフラグを立てる　←　未
	$_tmp = $_;	$_= $_." ";	while( s/\\listoftables[^a-zA-Z0-9\_]//o ){	$c_listoftables++;}	$_ = $_tmp;	#000527a
	if( s/^[ 	　]*($H_LineNum)表目次：/$1\"\\listoftables\"/o ){	$c_listoftables++;}

	$_tmp = $_;	$_= $_." ";	while( s/\\listoffigures[^a-zA-Z0-9\_]//o ){	$c_listoffigures++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)図目次：/$1\"\\listoffigures\"/o ){	$c_listoffigures++;}

	$_tmp = $_;	$_= $_." ";	while( s/\\tableofcontents[^a-zA-Z0-9\_]//o ){	$c_tableofcontents++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)目次：/$1\"\\tableofcontents\"/o ){	$c_tableofcontents++;}

	$_tmp = $_;	$_= $_." ";	while( s/\\title[^a-zA-Z0-9\_]//o ){	$c_title++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)題名：/$1\"\\title\{\"/o ){	$c_title++;}	# 000210a

	$_tmp = $_;	$_= $_." ";	while( s/\\author[^a-zA-Z0-9\_]//o ){	$c_author++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)作成：/$1\"\\author\{\"/o ){	$c_author++;}

	$_tmp = $_;	$_= $_." ";	while( s/\\date[^a-zA-Z0-9\_]//o ){	$c_++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)日付：/$1\"\\date\{\"/o ){	$c_date++;}

	$_tmp = $_;	while( s/\\begin\{abstract\}//o ){	$c_abstract++;}	$_ = $_tmp;
	if( s/^[ 	　]*($H_LineNum)要約：/$1\"\\begin\{abstract\}\"/o ){	$c_abstract++;}

	# if($f_papersetting){ # papersettingがあるときのみの設定 ==> 面倒だから常に変換するようにした。但し\usepackageはしないので必ず自分でいれる。
		$_tmp = $_;	while( s/\\abstract\{//o ){	$c_abstract_new++;}	$_ = $_tmp;
		if( s/^[ 	　]*($H_LineNum)概要：/$1\"\\abstract\{\"/o ){	$c_abstract_new++;}

		$_tmp = $_;	while( s/\\keywords\{//o ){	$c_keywords++;}	$_ = $_tmp;
		if( s/^[ 	　]*($H_LineNum)鍵：/$1\"\\keywords\{\"/o ){	$c_keywords++;}

		$_tmp = $_;	while( s/\\ENGtitle\{//o ){	$c_engtitle++;}	$_ = $_tmp;
		if( s/^[ 	　]*($H_LineNum)英語題：/$1\"\\ENGtitle\{\"/o ){	$c_engtitle++;}

		$_tmp = $_;	while( s/\\ENGauthor\{//o ){	$c_engauthor++;}	$_ = $_tmp;
		if( s/^[ 	　]*($H_LineNum)英語作：/$1\"\\ENGauthor\{\"/o ){	$c_engauthor++;}

		$_tmp = $_;	while( s/\\studentID\{//o ){	$c_studentID++;}	$_ = $_tmp; # 201101
		if( s/^[ 	　]*($H_LineNum)学番：/$1\"\\studentID\{\"/o ){	$c_studentID++;}

	# }

	if( /^[ 　	]*($H_LineNum)$/ | /^[ 	  ]*$/ ){	if( length($_percent)==0 ){	$c_kuugyou += 1;}else{	$f_ikinari_honbun+=1;}}	# 空行のカウント 縦棒2本？
	else{			$c_kuugyou = 0;}

	#---- %... があるとき、削除して後でつなぐ"
	if( length($_percent)>0 ){
		$_tmp='';	if( s/^[ 	　]*($H_LineNum)[ 	]*//o ){	$_tmp=$&;}
		if( length($_)==0 && $c_title==0 && $c_author==0 && $c_date==0 && $c_abstract==0 && $c_tableofcontents==0 && $c_documentstyle==0 && $c_usepackage_dvips==0 && $c_listoffigures==0 && $c_listoftables==0 ){	#020322a
			$H_OUT=$_tmp . '/*' . $nIgnor . '*/' . "\n";	&print_OUT_euc;	$ptnIgnor[$nIgnor] = $_percent;	$_percent = '';	$nIgnor++;	# 000309c
		}else{
			$_ = $_tmp.$_.'/*'.$nIgnor.'*/';	$ptnIgnor[$nIgnor] = $_percent;	$_percent = '';	$nIgnor++;	# 000210b
		}
	}


	#---- beginning処理の終了判定

	#		・beginning処理の終了条件は、'章：' or 空行の次の行が\aaa, {,}以外（\aaa以外は要約：のあとにある） or １行目から'題名：'や\aaaや空行など以外のとき
	# if( $c_kuugyou==2 || /\\section/ || /(章|節)：/ ||
	# if( /\\section/ || /[章節表図]：/ ||	#000530c, 000707m
	if( /\\section/ || /[章節表図](\*|\$\\ast\$|＊)*：/ ||	# 210701
		($c_kuugyou==1 && !(/^[ 	　]*($H_LineNum)[ 	\"]*[\~]*\\[a-zA-Z]/ || /^[	 　]*($H_LineNum)$/ || /^[ 	]*$/ )) ||
		# ($f_ikinari_honbun>=1 && !(/^[ 	　]*$H_LineNum[ 	\"]*[\~]*\\[a-zA-Z]/ || /^[	 　]*$H_LineNum[	 　\"\{\}]*$/ || /^[ 	]*$/)) ){
		# ($f_ikinari_honbun>=1 && !(/^[ 	　]*$H_LineNum[ 	\"]*[\~]*\\[a-zA-Z]/ || /^[	 　]*($H_LineNum)[	 　\"\{\}]*$/ || /^[ 	]*$/)) ){#030825a
		($f_ikinari_honbun>=1 && !(/^[ 	　]*($H_LineNum)[ 	\"]*[\~]*\\[a-zA-Z]/ || /^[	 　]*($H_LineNum)[	 　\"\{\}]*$/ || /^[ 	]*$/)) ){ # 括弧抜け200624
		# print $c_kuugyou.$f_ikinari_honbun."  ".$_."111\n";#"
		$_tmp_get_Beginning = $_;
		# for($i=0;$i<$nBeginning;$i++){print $c_kuugyou.'----'.$ptnBeginning[$i]."\n";}print '***********'."\n";
		&get_BEGINNING2;
		$f_beginning = 0;
		$_verbatim=~s/\n$//;	$H_OUT=$_verbatim."\n";	&print_OUT_euc;	#000813g
		$_ = $_tmp_get_Beginning;
	}else{
		#---- @ptnBeginning に貯める。
		$ptnBeginning[$nBeginning] = $_;
		$nBeginning += 1;
	}
	# if( !(/^[ 	]*H_LineNum$/) ){	# 空行以外のとき、いきなり本文フラグオフ
	if( !(/^[ 	]*($H_LineNum)$/) ){ # $が抜けてる200624
	# if( !(/^[ 	]*H_LineNum$/ || /^[ 	]*$/ || /^\/\*[0-9][0-9]*\*\/$/) ){	# 空行以外のとき、いきなり本文フラグオフ
		if( $f_ikinari_honbun!=0 ){$f_ikinari_honbun -= 1;}
	}
}

sub	get_BEGINNING2{	#	&get_BEGINNING2 ... \documentstyleなどを書く　＋　２重定義の処理
	if( $c_begin_document>0 ){	$c_begin_document0 = 1;}
	if( $c_documentstyle==0 ){
		if($H_a4j==1){	#000530i
			# 020322a	$ptnBeginning2[$nBeginning2] = '"\\documentstyle[psbox,a4j]{jarticle}"';	#000504b,000508b
			# $ptnBeginning2[$nBeginning2] = '"\\documentclass[a4j]{jarticle}"';	#020322a
			$ptnBeginning2[$nBeginning2] = '"\\documentclass[a4j]{jsarticle}"'; # 200624
		}else{
			# 020322a	$ptnBeginning2[$nBeginning2] = '"\\documentstyle[psbox]{jarticle}"';	#000504b,000508b
			# $ptnBeginning2[$nBeginning2] = '"\\documentclass[]{jarticle}"';	#020322a
			$ptnBeginning2[$nBeginning2] = '"\\documentclass[]{jsarticle}"'; #200624
		}
		$nBeginning2 += 1;
	}
	if( $c_usepackage_dvips==0 && $C_subfile != 1){ # 210701
		# $ptnBeginning2[$nBeginning2] = "\n".'"\\usepackage[dvips]{graphicx}"';
		$ptnBeginning2[$nBeginning2] = "\n".'"\\usepackage[dvipdfmx]{graphicx}"'; # 200624
		$nBeginning2 += 1;
	}
	if( $c_therefore==0 && $C_subfile != 1){ # 210701
		# $ptnBeginning2[$nBeginning2] = '"\\def\\therefore{\\setbox0 \\hbox{$\\cdot$}\\raise-0.2em \\copy0 \\raise0.2em \\copy0 \\raise-0.2em \\box0 ~}"';
		# $ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage{epsf}\usepackage{graphics}\usepackage{boxedminipage}\usepackage{epsfig}\usepackage{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}"';
		# $ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage[dvips]{graphicx}\usepackage{boxedminipage}\usepackage[fleqn]{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}\usepackage{type1cm}"';#120126
		if($H_PICTURE == 1){
			# $ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage{boxedminipage}\usepackage[fleqn]{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}\usepackage{type1cm}\usepackage{comment}\usepackage[hang,small,bf]{caption}\usepackage[subrefformat=parens]{subcaption}\captionsetup{compatibility=false}\graphicspath{{./picture/}}"'; # 200701
			$ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage{boxedminipage}\usepackage[fleqn]{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}\usepackage{type1cm}\usepackage{comment}\usepackage[format=hang,font=small,labelsep=quad,margin=20pt]{caption}\usepackage[subrefformat=parens]{subcaption}\captionsetup{compatibility=false}\graphicspath{{./picture/}}"'; # 200901
		}else{
			# $ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage{boxedminipage}\usepackage[fleqn]{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}\usepackage{type1cm}\usepackage{comment}\usepackage[hang,small,bf]{caption}\usepackage[subrefformat=parens]{subcaption}\captionsetup{compatibility=false}"'; # 200624
			$ptnBeginning2[$nBeginning2] = '"\usepackage{multicol}\usepackage{boxedminipage}\usepackage[fleqn]{amsmath}\usepackage{amssymb}\usepackage{ascmac}\usepackage{enumerate}\usepackage{url}\usepackage{type1cm}\usepackage{comment}\usepackage[format=hang,font=small,labelsep=quad,margin=20pt]{caption}\usepackage[subrefformat=parens]{subcaption}\captionsetup{compatibility=false}"'; # 200901
		}
		$nBeginning2 += 1;
	}
	if($C_subfile == 1){
		$ptnBeginning2[$nBeginning2] = '"\graphicspath{{picture/}{../picture/}}"';
		$nBeginning2++;
	}
	# if( $c_because==0 ){
		# $ptnBeginning2[$nBeginning2] = '"\\def\\because{\\setbox0\\hbox{$\\cdot$}\\raise0.2em \\copy0 \\raise-0.2em \\copy0 \\raise0.2em \\box0 ~}"';
		# $nBeginning2 += 1;
	# }
	if($H_a4j==0){	#000530i
		# if( $c_setlength_topmargin==0 ){
			# $ptnBeginning2[$nBeginning2] = '"\\setlength{\\topmargin}{5mm}"';
			# $nBeginning2 += 1;
		# }
		if( $c_setlength_headheight==0 ){
			$ptnBeginning2[$nBeginning2] = '"\\setlength{\\headheight}{0mm}"';
			$nBeginning2 += 1;
		}
		if( $c_setlength_textheight==0 ){
			# $ptnBeginning2[$nBeginning2] = '"\\setlength{\\textheight}{220mm}"';	#000508b
			$ptnBeginning2[$nBeginning2] = '"\\setlength{\\textheight}{250mm}"';	#000508b
			$nBeginning2 += 1;
		}
		if( $c_setlength_textwidth==0 ){
			# $ptnBeginning2[$nBeginning2] = '"\\setlength{\\textwidth}{150mm}"';
			$ptnBeginning2[$nBeginning2] = '"\\setlength{\\textwidth}{200mm}"';
			$nBeginning2 += 1;
		}
	}#000530i
	# if( $c_myheadings==0 ){
		# $ptnBeginning2[$nBeginning2] = '"\\pagestyle{myheadings}"';
		# $nBeginning2 += 1;
	# }
	$f_finding_migityuukakko = 0;
	$f_finding_end_abstract = 0;
	for($i=0;$i<$nBeginning;$i++){
		$_ = $ptnBeginning[$i];
		$_=$_." ";	#000527a
		# #---- %... があるとき、削除して後でつなぐ
		# if( s/(\%.*)$// ){	$_percent = $&;}

		if( $c_documentstyle > 0 && /\\documentstyle[^a-zA-Z0-9\_]/ ){	#000527a
			if( ($c_documentstyle-1) > 0 ){
				s/(\\documentstyle)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\documentstyleが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\documentstyleが複数定義されているのでコメントしました。');
			}
		}
		if( $c_documentstyle > 0 && /\\documentclass[^a-zA-Z0-9\_]/ ){	#020322a
			if( ($c_documentstyle-1) > 0 ){
				s/(\\documentclass)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\documentclassが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\documentclassが複数定義されているのでコメントしました。');
			}
		}
		if( $c_therefore > 0 && /\\def[     ]*\\therefore[^a-zA-Z0-9\_]/ ){
			if( ($c_therefore-1) > 0 ){
				s/(\\def[ 	]*\\therefore)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\def\\thereforeが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\def\\thereforeが複数定義されているのでコメントしました。');
			}
		}
		if( $c_because > 0 && /\\def[     ]*\\because[^a-zA-Z0-9\_]/ ){
			if( ($c_because-1) > 0 ){
				s/(\\def[ 	]*\\because)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\def\\becauseが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\def\\becauseが複数定義されているのでコメントしました。');
			}
		}
		if( $c_setlength_topmargin > 0 && /\\setlength[   ]*\{[   ]*\\topmargin[^a-zA-Z0-9\_]/ ){
			if( ($c_setlength_topmargin-1) > 0 ){
				s/(\\setlength[ 	]*\{[ 	]*\\topmargin)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\setlength{\\topmarginが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\setlength{\\topmarginが複数定義されているのでコメントしました。');
			}
		}
		if( $c_setlength_headheight > 0 && /\\setlength[   ]*\{[   ]*\\headheight[^a-zA-Z0-9\_]/ ){
			if( ($c_setlength_headheight-1) > 0 ){
				s/(\\setlength[ 	]*\{[ 	]*\\headheight)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\setlength{\\headheightが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\setlength{\\headheightが複数定義されているのでコメントしました。');
			}
		}
		if( $c_setlength_textheight > 0 && /\\setlength[   ]*\{[   ]*\\textheight[^a-zA-Z0-9\_]/ ){
			if( ($c_setlength_textheight-1) > 0 ){
				s/(\\setlength[ 	]*\{[ 	]*\\textheight)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\setlength{\\textheightが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\setlength{\\textheightが複数定義されているのでコメントしました。');
			}
		}
		if( $c_setlength_textwidth > 0 && /\\setlength[   ]*\{[   ]*\\textwidth[^a-zA-Z0-9\_]/ ){
			if( ($c_setlength_textwidth-1) > 0 ){
				s/(\\setlength[ 	]*\{[ 	]*\\textwidth)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\setlength{\\textwidthが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\setlength{\\textwidthが複数定義されているのでコメントしました。');
			}
		}
		if( $c_myheadings > 0 && /\\pagestyle[^a-zA-Z0-9\_]/ ){
			if( ($c_myheadings-1) > 0 ){
				s/(\\pagestyle)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\pagestyleが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\pagestyleが複数定義されているのでコメントしました。');
			}
		}
		if( $c_begin_document > 0 && /\\begin[   ]*\{[   ]*document[     ]*\}/ ){
			$f_begin_document_not_yet = 0;				# \begin{document}出力済
			if( ($c_begin_document-1) > 0 ){
				s/(\\begin[ 	]*\{[ 	]*document[ 	]*\})/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\begin{document}が複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\begin{document}が複数定義されているのでコメントしました。');
			}
		}
		if( $c_maketitle > 0 && /\\maketitle[^a-zA-Z0-9\_]/ ){
			if( ($c_maketitle-1) > 0 ){
				s/(\\maketitle)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\maketitleが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\maketitleが複数定義されているのでコメントしました。');
			}
		}
		if( $c_listoftables > 0 &&  /\\listoftables[^a-zA-Z0-9\_]/ ){
			if( ($c_listoftables-1) > 0 ){
				s/(\\listoftables)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\listoftablesが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\listoftablesが複数定義されているのでコメントしました。');
			}
		}
		if( $c_listoffigures > 0 && /\\listoffigures[^a-zA-Z0-9\_]/ ){
			if( ($c_listoffigures-1) > 0 ){
				s/(\\listoffigures)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\listoffiguresが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\listoffiguresが複数定義されているのでコメントしました。');
			}
		}
		if( $c_tableofcontents > 0 && /\\tableofcontents[^a-zA-Z0-9\_]/){
			if( ($c_tableofcontents-1) > 0 ){
				s/(\\tableofcontents)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\tableofcontentsが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\tableofcontentsが複数定義されているのでコメントしました。');
			}
		}
		if( $f_finding_migityuukakko && $C_subfile != 1){	# 空行 or ○○： or \abc のとき前の行に } をつける メモ！ => 縦横はいる？ 200624

			# if( /^[ 　	]*($H_LineNum) $/ || /^[ 	]*($H_LineNum)[ 	]*(章|節|図|表|定理|補題|証明)：/ || /^[ 	]*($H_LineNum)[ 	\"]*(\\[a-zA-Z])/ ){	#000527a,000625a
			if( /^[ 　	]*($H_LineNum) $/ || /^[ 	]*($H_LineNum)[ 	]*(章|節|図|表|定理|補題|証明)(\*|\$\\ast\$|＊)*：/ || /^[ 	]*($H_LineNum)[ 	\"]*(\\[a-zA-Z])/ ){	# 210701
				$ptnBeginning2[$nBeginning2-1] = $ptnBeginning2[$nBeginning2-1].'"}"';
				$f_finding_migityuukakko = 0;
			}
		}
		if( $f_finding_end_abstract ){	# 空行 or ○○： or \abc のとき前の行に } をつける

			# if( /^[ 　	]*($H_LineNum)$/ || /^[ 	]*(章|節|図|表|定理|補題|証明)：/ || /^[ 	]*(\\[a-zA-Z])/ ){#"
			# if( /^[ 　	]*($H_LineNum) $/ || /^[ 	]*(章|節|図|表|定理|補題|証明)：/ || /^[ 	]*(\\[a-zA-Z])/ ){	#000527a
			if( /^[ 　	]*($H_LineNum) $/ || /^[ 	]*(章|節|図|表|定理|補題|証明)(\*|\$\\ast\$|＊)*：/ || /^[ 	]*(\\[a-zA-Z])/ ){	# 210701
				$ptnBeginning2[$nBeginning2] = '"\\end{abstract}"';	$f_finding_end_abstract = 0;	#000408b
				$nBeginning2 += 1;
				$f_finding_end_abstract = 0;
			}
		}
		# if( $c_begin_document0==0 && $f_begin_document==1 ){ # begin{document}をtitleの直前に入れる 200701
		# 	if( $f_finding_migityuukakko==0 && $f_finding_end_abstract==0 ){
		# 		$f_begin_document_not_yet = 0;				# \begin{document}出力済
		# 		$ptnBeginning2[$nBeginning2] = '"\\begin{document}"';
		# 		$nBeginning2 += 1;
		# 		$f_begin_document=0;
		# 	}
		# }
		if( $c_title > 0 && /\\title[^a-zA-Z0-9\_]/ ){	#000527a
			if($c_begin_document == 0){# begin{document}をtitleの直前に入れる 200701
				$f_begin_document_not_yet = 0;				# \begin{document}出力済 
				$ptnBeginning2[$nBeginning2] = '"\\begin{document}"';
				$nBeginning2 += 1;
				$f_begin_document=0;
			}
			if( ($c_title-1) > 0 ){
				s/(\\title)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\titleが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\titleが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン
				}

				if($f_papersetting){ # papersetting用 200701
					$titleold = $_;
					if($titleold =~ /(.*)\"\\title\{\"(.*)/){
						$titlenew = $1 . "\"\\title\{" . $n_papersetting . "\}\{\"" . $2;
						$_ = $titlenew;
					}
				}
			}
		}
		if( $c_engtitle > 0 && /\\ENGtitle[^a-zA-Z0-9\_]/ ){	#000527a
			if( ($c_engtitle-1) > 0 ){
				s/(\\ENGtitle)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\ENGtitleが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\ENGtitleが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン
				}

				if($f_papersetting){ # papersetting用 200701
					$engtitleold = $_;
					if($engtitleold =~ /(.*)\"\\ENGtitle\{\"(.*)/){
						$engtitlenew = $1 . "\"\\ENGtitle\{" . $n_papersetting . "\}\{\"" . $2;
						$_ = $engtitlenew;
					}
				}
			}
		}
		if( $c_author > 0 && /\\author[^a-zA-Z0-9\_]/ ){
			if( ($c_author-1) > 0 ){
				# 030408 s/(\\author)/\%$1/;#"
				# 030408 &getLineNum;	&print_warning('% txt2tex Error('.$LineNum.'): \\authorが複数定義されているのでコメントしました。'."\n");
				&getLineNum;	&print_warning('% txt2tex Error('.$LineNum.'): \\authorを複数定義するとlatexエラーが起こり、dvi, pdfファイルを作成できないかも。'."\n");#030408
				&insrt_matoato_warning($LineNum,'\\authorを複数定義するとlatexエラーが起こり、dvi, pdfファイルを作成できないかも。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){	$f_finding_migityuukakko = 1;}	# 行末に } がないとき、探すフラグをオン"

				if($f_papersetting){ # papersetting用 200701
					$authorold = $_;
					if($authorold =~ /(.*)\"\\author\{\"(.*)/){
						$authornew = $1 . "\"\\author\{" . $n_papersetting . "\}\{\"" . $2;
						$_ = $authornew;
					}
				}

				# $f_begin_document = 1; # begin{document}をtitleの直前に入れる 200701
			}
		}
		if( $c_engauthor > 0 && /\\ENGauthor[^a-zA-Z0-9\_]/ ){	#000527a
			if( ($c_engauthor-1) > 0 ){
				s/(\\ENGauthor)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\ENGauthorが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\ENGauthorが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン
				}

				if($f_papersetting){ # papersetting用 200701
					$engauthorold = $_;
					if($engauthorold =~ /(.*)\"\\ENGauthor\{\"(.*)/){
						$engauthornew = $1 . "\"\\ENGauthor\{" . $n_papersetting . "\}\{\"" . $2;
						$_ = $engauthornew;
					}
				}
			}
		}
		if( $c_date > 0 && /\\date[^a-zA-Z0-9\_]/ ){
			if( ($c_date-1) > 0 ){
				s/(\\date)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\dateが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\dateが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){	$f_finding_migityuukakko = 1;}	# 行末に } がないとき、探すフラグをオン"

			}
		}
		if( $c_abstract > 0 && /\\begin\{abstract\}/ ){
			if( ($c_abstract-1) > 0 ){
				s/(\\begin\{abstract\})/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\begin{abstract}が複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\begin{abstract}が複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !($style_file eq "sice") ){	#000507a
					if( $c_maketitle==0 ){	#000408a, sice.styのときはここをコメントする
						&set_maketitle;
						$c_maketitle++;
					}
				}
				if( !(s/\\end\{abstract\}(.*)$//) ){	$f_finding_end_abstract = 1;}	# 行末に\end{abstract}がないとき、探すフラグをオン

				else{	$ptnBeginning2[$nBeginning2] = $_;	$_ = $&;	$nBeginning2 += 1;}
			}
		}
		if( $c_abstract_new > 0 && /\\abstract\{/ ){ # 200701
			if( ($c_abstract_new-1) > 0 ){
				s/(\\abstract\{)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\abstractが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\abstractが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン"
				}
			}
		}
		if( $c_keywords > 0 && /\\keywords\{/ ){ # 200701
			if( ($c_keywords-1) > 0 ){
				s/(\\keywords\{)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\keywordsが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\keywordsが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン"
				}
			}
		}
		if( $c_studentID > 0 && /\\studentID\{/ ){ # 201101
			if( ($c_studentID-1) > 0 ){
				s/(\\studentID\{)/\%$1/;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\studentIDが複数定義されているのでコメントしました。'."\n");
				&insrt_matoato_warning($LineNum,'\\studentIDが複数定義されているのでコメントしました。');
			}else{					# 有効な \title のとき
				if( !(/\}[ 	\"]*$/) ){
					$f_finding_migityuukakko = 1;	# 行末に } がないとき、探すフラグをオン"
				}
			}
		}
		s/ $//;	#000527a

		# ---- %... があるとき、削除して後でつなぐ
		# $_ = $_.$_percent;	$_percent = '';
		# $_ = $_.'/*'.$nIgnor.'*/';	$ptnIgnor[$nIgnor] = $_percent;	$_percent = '';	$nIgnor++;	# 000210b

		#---- @ptnBeginning2 に貯める。
		if($C_subfile != 1){ # 210701
			$ptnBeginning2[$nBeginning2] = $_;
			$nBeginning2 += 1;
		}
	}
	if( $c_maketitle==0 ){	# 最後？
		&set_maketitle;
		# if( $f_begin_document_not_yet ){	# 000309c
			# $ptnBeginning2[$nBeginning2] = '"\\begin{document}"';
			# $nBeginning2 += 1;
		# }
		# $ptnBeginning2[$nBeginning2] = '"\\maketitle"'."\n";
		# $nBeginning2 += 1;
	}	
	&get_BEGINNING3;
}

sub	get_BEGINNING3{	#	&get_BEGINNING3 ... 順番による latex error を避けるように順序入れ替え　＋　出力, 000403a修正
	my	($i, @imem, $n);

	$nBeginning = 0;
	$n=0;	$f = 0;			# \begin{document}を書くと１
	for($i=0;$i<$nBeginning2;$i++){
		$_ = $ptnBeginning2[$i];
		if( length($_)==0 ){	next;}
		if( $f==0 ){
			if( /\\tableofcontents/ || /\\listoftables/ || /\\listoftables/ ){
				$imem[$n]=$i;	$n++;	next;
			}
		}
		if( /\\title\{/ || /\\author/ || /\\begin\{document\}/ || /\\date\{/ || /\\maketitle/ ){
			$H_OUT='%'."\n";	&print_OUT_euc;
		}
		$H_OUT=$_."\n";	&print_OUT_euc;
		if( /\\maketitle/ ){
			$H_OUT='%'."\n";	&print_OUT_euc;
		}
		if( /\\begin[ 	]*\{[ 	]*document[ 	]*\}/ ){	$f=1;}
	}
	if( $f==1 ){	#000605c
		for($i=0;$i<$n;$i++){
			$H_OUT=$ptnBeginning2[$imem[$i]]."\n";	&print_OUT_euc;
		}
	}
	for($i=0;$i<$nBeginning;$i++){ # いる？200624
		$H_OUT=$ptnBeginning[$i]."\n";	&print_OUT_euc;
	}
	if( $c_abstract==1 && $f_finding_end_abstract==1 ){	$H_OUT=$H_next."\\end{abstract}\n";	&print_OUT_euc;}	#000408b

 if( $H_f_write_theorem && ($C_subfile != 1)){#020322e
	$H_OUT=$H_next."\\newtheorem\{theorem\}\{定理\}\n";	&print_OUT_euc;	#000213c
	$H_OUT=$H_next."\\newtheorem\{lemma\}\{補題\}\n";	&print_OUT_euc;
	if( $style_file ne "IEEEtran" ){	#000707o
		$H_OUT=$H_next."\\newtheorem\{proof\}\{証明\}\n";	&print_OUT_euc;
	}
 }
}
#-------------------- begin
#	●\titleなど何もないのに\maketitleするとlatex warning　← このとき\maketitleを書かない, 000317a
#		\maketitleは、\title,\authorがないとlatex warning、\dateがないと日付が自動的に書かれる

#			→ \title, \author, \date, abstractのいずれかがあると\maketitleを書き、上記３つのどれかないとき\date{}などをかく
sub	set_maketitle{
	if( $c_title==0&&$c_author==0&&$c_date==0&&$c_abstract==0&&$c_tableofcontents==0&&$c_documentstyle==0&&$c_listoffigures==0&&$c_listoftables==0 ){
		if( $f_begin_document_not_yet ){	# 000309c
			$ptnBeginning2[$nBeginning2] = '"\\begin{document}"';	$nBeginning2 += 1;
		}
	}else{
		if( !($style_file eq "sice") && $C_subfile != 1){	#000507a
			if( $c_title==0 ){
				$ptnBeginning2[$nBeginning2] = '"\\title{　}"';	$nBeginning2 += 1;	#000707p
			}
			if( $c_author==0 ){
				# 030317 $ptnBeginning2[$nBeginning2] = '"\\author{}"';	$nBeginning2 += 1;
			}
			if( $c_date==0 ){
				$ptnBeginning2[$nBeginning2] = '"\\date{}"';	$nBeginning2 += 1;
			}
		}
		if( $f_begin_document_not_yet ){	# 000309c
			$ptnBeginning2[$nBeginning2] = '"\\begin{document}"';	$nBeginning2 += 1;
		}
		if($C_subfile != 1){$ptnBeginning2[$nBeginning2] = '"\\maketitle"';	$nBeginning2 += 1;} # 210701
	}
}
	#-------------------- end

#	warning message を画面とファイルに出力
sub	print_warning{
	$H_OUT=$_[0];
	&print_($H_OUT);
	$H_OUT=$H_next.$H_OUT;
	&print_OUT_euc;
}

sub	debug000430b{
	s/^[ 	　]*($H_LineNum)表目次：/$1\"\\listoftables\"/o;
	s/^[ 	　]*($H_LineNum)図目次：/$1\"\\listoffigures\"/o;
	s/^[ 	　]*($H_LineNum)目次：/$1\"\\tableofcontents\"/o;
}
#------------------------------------"
#	タイトル等の開始処理(end)
#------------------------------------







#------ 下付き Tave → T_{ave} にする処理(begin) ---------
#	txtファイル： abc,		a_bc
#	TeXファイル： a_{bc},	a_{b_c}
#初期設定

#	&define_LaTeXmoji;
#	●txt2tex:debug: simotuki新規書き直し, 000510c
sub simotuki{
	my	($ptn_eq, $_bef, $_aft, $ptn1, $ptn2, $tmp);

	$ptn_eq = $def_txt_hensuuAll.'a-zA-Z';
	# $_bef='';
	$_aft='';
	while( s/(.*[^0-9$ptn_eq])([$ptn_eq])([0-9$ptn_eq]+)// ||
	# while( s/(.*[^\_0-9$ptn_eq])([$ptn_eq])([0-9$ptn_eq]+)// ||
		   s/^()([$ptn_eq])([0-9$ptn_eq]+)// ){
		$_bef=$1;	$_aft=$_.$_aft;	$ptn1=$2;	$ptn2=$3;	$tmp=$ptn1.$ptn2;
		if( $_bef=~/\\$/ ||
			# 000801eで参考にした
		  $tmp =~ /^(dt|Cos|cos|COS|Sin|sin|SIN|Tan|tan|TAN|Atan|ATan|atan|ATAN|Exp|exp|EXP|lim|LaTeX2e|LaTeX|TeX|Figure|figure|Fig|fig|Table|table|max|min)$/ ){
			$_=$_bef;	$_aft=$ptn1.$ptn2.$_aft;
		}else{
			$_=$_bef;	$_aft='{'.$ptn1.'_{'.$ptn2.'}}'.$_aft;
		}
	}
	$_=$_.$_aft;

	# a_n1 --> a_{n1} ... これは an1 と等価なので不要
	# s/\_([$ptn_eq][0-9$ptn_eq]+)/\_\{$1$2\}/g;

	# ●txt2tex:debug: a1^(2)→{a_{1}}^\left(2\right)→{a_{1}^{\left(2\right)}}, 000510a(begin)
	s/\}\}[ 	]*(\^[0-9\.$ptn_eq]+)/\}$1\}/g;	# MP^(a+b) 以外000506c
	while( s/^(.*[0-9$ptn_eq])(\}\}[ 	]*\^[ 	]*)([\(\{\[｛][ 	]*[\-\+]*[0-9\.$ptn_eq]+)/$3/ ){
		$tmp_ = $1.'}^';	$tmp = &get_kakko_nakami_LtoR('');
		if( $tmp=~/^\{/ ){	$_ = $tmp_.$tmp.'}'.$_;}
		else{				$_ = $tmp_.'{'.$tmp.'}}'.$_;}
	}
	# ●txt2tex:debug: a1^(2)→{a_{1}}^\left(2\right)→{a_{1}^{\left(2\right)}}, 000510a(end)
}

#------ 下付き Tave → T_{ave} にする処理(end) ---------


#------ ＾a, ~b, ￣ {c+d} を {＾a}, {~b}, {￣{c+d}}にする (begin)000426a
#------ ＾~￣α → ＾{~{￣α}}, 000430f
#a/b, a/b(t), a/b(t), (1+a)/b(t), (a+b)/b, a/(b+c), a(t)/(b+1), a/＾￣~b
#β1(t)/Φa(t), (a+b)(c+d)/(e+f)(g+h), ((a+b)(c+d))/((e+f)(g+h)), a/b/c/d/e
#a^~b/c_＾d, a^~b/c_＾(a(t)+b(t))
#＾~￣α^{β+ab}_{γ-δ}
sub	tilde_tyuukakko{
	my	($ptn_eq, $_tmp, $nakami);

	chop;
	$ptn_eq = $def_txt_hensuuAll.'a-zA-Z0-9\\\.';		# ＾\~￣の中に入る文字

	#------ ＾a, ~b, ￣ {c+d} を {＾a}, {~b}, {￣{c+d}}にする

	while( s/([^\(\{\[｛][ 	]*)([＾\~￣])[ 	]*([$ptn_eq]+)/$1\{$2$3\}/g ){}
	s/^([ 	]*)([＾\~￣])[ 	]*([$ptn_eq]+)/$1\{$2$3\}/;
	while( s/([^\(\{\[｛][ 	]*)([＾\~￣])[ 	]*([\(\{\[｛][ 	]*[$ptn_eq].*)/$1\{$2/ ){
		$_tmp = $_;	$_ = $3;	$nakami = &get_kakko_nakami_LtoR('');	$_ = $_tmp.'{'.$nakami.'}}'.$_;
	}

	#------ ＾~￣α → ＾{~{￣α}}
	while( s/([＾\~￣])[ 	]*([＾\~￣])[ 	]*([$ptn_eq]+)([\(\{\[｛]*)(.*)/$1\{$2$3/ ){	#＾~￣α→＾~{￣α}
		if( length($4)>1 ){
			$_tmp = $_;	$_ = $4.$5;	$nakami = &get_kakko_nakami_LtoR('');	$_ = $_tmp.$nakami.'}'.$_;
		}else{
			$_ = $_.'}'.$5;
		}
	}
	while( s/([＾\~￣])[ 	]*([＾\~￣])[ 	]*([\(\{\[｛]+[ 	]*[＾\~￣]*[$ptn_eq]+.*)/$1\{$2/ ){	#＾~{￣α}→＾{~{￣α}}
		$_tmp = $_;	$_ = $3;	$nakami = &get_kakko_nakami_LtoR('');	$_ = $_tmp.$nakami.'}'.$_;
	}

	#------ ＾(a(t)+b(t)) → ＾{(a(t)+b(t))} 000625f
	while( s/([＾\~￣])[ 	]*([\(\[｛]+[ 	]*[＾\~￣]*[$ptn_eq]+.*)/$1\{/ ){
		$_tmp = $_;	$_ = $2;	$nakami = &get_kakko_nakami_LtoR('');	$_ = $_tmp.$nakami.'}'.$_;
	}

	while( s/([＾\~￣])([ 	]*[^$ptn_eq\(\{\[｛])/$1\{\}$2/g ){}	# ＾\~￣の中身がないとき{}を挿入
	$_ = $_."\n";
}

# Usage: $kakko_nakami = &get_kakko_nakami_LtoR('');	$_ = $kakko_nakami.$_;
# input: $_ = '(.()..):::'
# output: return '(.()..)', $_ = ':::'
# called by &tilde_tyuukakko, &frac
sub	get_kakko_nakami_LtoR{	#L2R
	my	($right, $left, $n, $nl, $nr, $den, $tmp);

	s/^.//;	$left = $&;
	if(		$left eq '(' ){		$right = ')';}
	elsif(	$left eq '{' ){		$right = '}';}
	elsif(	$left eq '[' ){		$right = ']';}
	elsif(	$left eq '｛' ){	$right = '｝';}
	else{	&print_($left.$_."Error Error Error Error 00422b\-2\n\n");}

	$nl = 1;	$nr = 0;	$den=$left;	while( s/^[$left]// ){	$nl++;	$den = $den.$left;}
	while( $nr != $nl ){
		if( s/^([^$right]*[$right])// ){	# /(..(...):::)/ の ::: を抽出
			$nr++;	$den = $den.$1;
			$tmp = $_;	$_ = $1;	$n = s/[$left]//g;	$nl += $n;	$_ = $tmp;
		}else{
			if($_[0] ne "quiet"){
				&print_($left.$nl.$right.$nr."  ".$den."  ".$_."Error Error Error Error 00422b\-5\n\n");
			}
			last;
		}
	}
	return $den;
}

# Usage: $kakko_nakami = &get_kakko_nakami_RtoL;	$_ = $_.$kakko_nakami;
# input: $_ = ':::(.()..)'
# output: return '(.()..)', $_ = ':::'
# called by &tilde_tyuukakko, &frac
sub	get_kakko_nakami_RtoL{	#R2L
	my	($right, $left, $n, $nl, $nr, $num, $tmp);

	s/.$//;	$right = $&;
	if(		$right eq ')' ){	$left = '(';}
	elsif(	$right eq '}' ){	$left = '{';}
	elsif(	$right eq ']' ){	$left = '[';}
	elsif(	$right eq '｝' ){	$left = '｛';}
	else{	&print_("Error Error Error Error 00422b\-1\n\n");}

	$nl = 0;	$nr = 1;	$num = $right;	while( s/[$right]$// ){	$nr++;	$num = $right.$num;}
	while( $nr != $nl ){
		if( s/([$left][^$left]+)$// ){	# (:::(...)..)/ の ::: を抽出
			$nl++;	$num = $1.$num;
			$tmp = $_;	$_ = $1;	$n = s/[$right]//g;	$nr += $n;	$_ = $tmp;
			if( $nr==$nl ){	last;}	while( s/[$left]$// ){	$nl++;	$num = $&.$num;	if( $nr==$nl ){	last;}}
		}else{	&print_($left.$nl.$right.$nr."Error Error Error Error 00422b\-4\n\n");	last;}
	}
	return $num;
}
# (end)000426a

# Usage: $tmp=&get_verb_nakami;
#	'aaa\verb|bbb|ccc'のとき $_='|bbb|ccc'にして、$tmp=&get_verb_nakami; を実行
#	→ $tmp='|bbb', $_='|ccc' となる

# input: $_ = '|bbb|ccc'
# output: return '|bbb', $_='|ccc'
#	新規作成000623c
sub	get_verb_nakami{
	my	($out);

	s/^(.)/$1/;
	s/($1[^$1]*)//;	$out=$_;	$_=$&;
	return	$out;
}
# (end)000623c

#------------------------------------
#	かっこ ( → \left(，）→ \right), kakko2tex (begin)
#------------------------------------
sub init_kakko2tex{
	&init_debug_eqn;
}

sub check_kakko2tex{
	&check_debug_eqn;
}

sub kakko2tex{
	# かっこ ( → \left(	(begin)
	s/\(/\\left(/g;
	s/\)/\\right)/g;
	s/\[/\\left[/g;
	s/\]/\\right]/g;
	# かっこ ( → \left(	(end)

	if( s/\\left.*// ){	#020323b
		$_1 = $&;
		s/\n//;
		# print $_.$_1."\n";
		while( s/\\right// ){	$_1=~s/(.*)\\left/$1/;}
		$_ = $_.$_1."\n";
		# print;
	}

	# if( /^	/o && !(/表：/o || /図：/o) && $fHyou==0){ # 式の抽出, 981119b
	# 左括弧と右括弧の数が合ってないとき \left. を書いて Warning を書く
	# if( !(/\&/) ){
	if( $fdebug_eqn2==0 || !(/\,/) ){	#980922, NG array以外もかかる

		&add_kakko;
	}else{
	# うまくいってない
		$new_ = '';	$bef_='';	chop;
		# while( /(.*)(\&)(.*)$/ ){	# & の区切りごとにかっこが対応しないといけない
		while( /(.*)(\,)(.*)$/ ){	# & の区切りごとにかっこが対応しないといけない	#980922, NG array以外もかかる

			$bef_ = $1;	$kigou_ = $2;	$aft_ = $3;
			# $bef_ = $1;	$aft_ = $2;
			$_ = $aft_;
			&add_kakko;
			$aft_ = $_;
			# $new_ = $aft_.'&'.$new_;
			$new_ = $kigou_.$aft_.$new_;
			# print $new_."\n";
			$_ = $bef_;
		}
		$_ = $bef_;
		&add_kakko;
		$bef_ = $_;
		$_ = $bef_.$new_;#."\n";
		s/\n//g;	$_ = $_."\n";
	}
	# {v_{u}}	&:& u相電圧
	# }#981119b
}

#	左括弧と右括弧の数が合ってないとき \left. を書いて Warning を書く(begin)
#	中カッコ\{...\}も追加 000213b
sub	add_kakko{
	$count_left  = tr/\(|\[｛//;	# 000213b
	$count_right = tr/\)|\]｝//;	# 000213b
	# $_tmp2 = $_;	while( s/\\\{// ){	$count_left++;}	while( s/\\\}// ){  $count_right++;}	$_ = $_tmp2;	# 000213b
	if( $count_left>$count_right ){
		# for($i=0;$i<$count_left-$count_right;$i++){	# 最初の\rightに\right.をつける

			# s/\\right/\\right. \\right/;
		# }
		# chop;
		# for($i=0;$i<$count_left-$count_right;$i++){	# 文末に\right.をつける

			# @ptn = /(\\right)(.)(.*)$/;
			# s/\\right(.*)$//;
			# $_ = $_."\\right".$ptn[1]."\\right.".$ptn[2];
			# $_ = $_."\\right.";
		# }
		# $_ = $_."\n";

		# debug OK! 行列の要素ごとにチェックすべきが行ごとになっている．'	& ' で区切ってみるか！
		# 980922　２重にchopすると最後の文字が消える		chop;
		&inverse;
		$tmp = '.thgir\ ' x ($count_left-$count_right);	# 最後の\left)}]のあとにに\right.をつける

		# 980922		chop;
		$_new = '';	$f = 0;
		while(length($_)>0){
			s/^.//;	@ptn = $&;
			# if( ($f==0) && ($ptn[0] eq '(' || $ptn[0] eq '{' || $ptn[0] eq '[' || $ptn[0] eq ')' || $ptn[0] eq '}' || $ptn[0] eq ']' ) ){
			if( ($f==0) && ($ptn[0] eq '(' || $ptn[0] eq '{' || $ptn[0] eq '[' || $ptn[0] eq ')' || $ptn[0] eq '}' || $ptn[0] eq ']' || $ptn[0] eq '｛' || $ptn[0] eq '｝' ) ){	# 000213b
				$_new = $_new.$tmp.$&;
				$f = 1;
			}else{
				$_new = $_new.$&;
			}
		}
		if( $f==0 ){
			$_new = $_new.$tmp;
		}
		# $_ = $_new."\n";#980909
		$_ = $_new;#980922
		&inverse;
		$_ = $_."\n";#980922

		if( !($count_left==1 & $count_right==0) ){	# 000428c
			&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): 左カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right."\n");
			&insrt_matoato_warning($LineNum,'左カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right);
		}
	}elsif( $count_left<$count_right ){
		if(1){
			$tmp = ' \\left.' x ($count_right-$count_left);
			if(  /\\left/ ){
				s/\\left/$tmp\\left/;
			}else{
				s/\\right/$tmp\\right/;
			}
		}else{
			$f = 0;
			for($i=0;$i<$count_right-$count_left;$i++){
				if( s/\\left/\\left. \\left/ ){	$f = 1;}
			}
			if( $f==0 ){
				for($i=0;$i<$count_right-$count_left;$i++){
					s/\\right/\\left. \\right/;
				}
			}
		}
		if( !($count_left==0 & $count_right==1) ){	# 000428c
			&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): 右カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right."\n");
			&insrt_matoato_warning($LineNum,'右カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right);
		}
	}

	s/｛/\\left\\{/g;	# 000213b
	s/｝/\\right\\}/g;	# 000213b
}
#	左括弧と右括弧の数が合ってないとき \left. を書いて Warning を書く(end)

#------------------------------------
#	かっこ ( → \left(，）→ \right), kakko2tex (end)
#------------------------------------






#------ 全角文字のLaTeX文字への置換えの処理(begin) ---------000801f
#初期設定

#	&define_LaTeXmoji;
sub LaTeXmoji{
	my	($ptn);

	chop;	$_=$_." ";
	$ptn = ' 	\\\{\}\(\)\[\]｛｝\-\+\_\^\$';
	for($i=0;$i<=$#def_txt_hensuu;$i++ ){
		s/[$def_txt_hensuu[$i]]([$ptn])/$def_tex_hensuu[$i]$1/g;	#perl580bug: /×/:NG, /[×]/:OK
		s/[$def_txt_hensuu[$i]]/$def_tex_hensuu[$i] /g;				#perl580bug: /×/:NG, /[×]/:OK
	}
	for($i=0;$i<=$#def_txt_moji;$i++ ){
		s/[$def_txt_moji[$i]]([$ptn])/$def_tex_moji[$i]$1/g;		#perl580bug: /×/:NG, /[×]/:OK
		s/[$def_txt_moji[$i]]/$def_tex_moji[$i] /g;					#perl580bug: /×/:NG, /[×]/:OK
	}

	s/・・・([$ptn])/\\cdots$1/g;			s/・・・/\\cdots /g;
	s/．．．([$ptn])/\\ldots$1/g;			s/．．．/\\ldots /g;
	s/\.\.\.([$ptn])/\\ldots$1/g;			s/\.\.\./\\ldots /g;
	s/\+\-([$ptn])/\\pm$1/g;				s/\+\-/\\pm /g;
	s/\-\+([$ptn])/\\mp$1/g;				s/\-\+/\\mp /g;
	s/←→([$ptn])/\\Leftrightarrow$1/g;	s/←→/\\Leftrightarrow /g;
	s/↑↓([$ptn])/\\Updownarrow$1/g;		s/↑↓/\\Updownarrow /g;
	s/↓↑([$ptn])/\\Updownarrow$1/g;		s/↓↑/\\Updownarrow /g;

	s/ $//;	$_=$_."\n";

	&abs_norm;

	# ●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ → Warningする, 981121d, begin
	if( /(・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|①|②|③|④|⑤|⑥|⑦|⑧|⑨|⑩|⑪|⑫|⑬|⑭|⑮|⑯|⑰|⑱|⑲|⑳|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|≡|・ｽ・ｽ|∫|∮|√|⊥|∠|∟|⊿|∵|∩|∪|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|遑ポ遑楯遑ｨ|・弓博|遖ｱ|箞|遽慾邁－ｶ｡|邊ｼ|邉怖・|・|・|・|・)/ ){ # unixで表示できない外字一覧

		&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):外字"'.$1.'"は表示と印刷ができないかも？'."\n");
		&insrt_matoato_warning($LineNum,'外字"'.$1.'"は表示と印刷ができないかも？');
	}
	# ●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ → Warningする, 981121d, end
}

sub LaTeXmoji2{	#000605b
	$_=" ".$_." ";
	s/([^a-zA-Z0-9\_\\])(Cos|cos|COS)([^a-zA-Z\_])/$1\\cos $3/g;
	s/([^a-zA-Z0-9\_\\])(Sin|sin|COS)([^a-zA-Z\_])/$1\\sin $3/g;
	s/([^a-zA-Z0-9\_\\])(Tan|tan|TAN)([^a-zA-Z\_])/$1\\tan $3/g;
	s/([^a-zA-Z0-9\_\\])(Atan|ATan|atan|ATAN|Arctan|arctan|ARCTAN)([^a-zA-Z\_])/$1\\tan\^{-1} $3/g;
	s/([^a-zA-Z0-9\_\\])(Exp|exp|EXP)([^a-zA-Z\_])/$1\\exp $3/g;
	s/([^a-zA-Z0-9\_\\])(LaTeX2e|LaTeX|TeX|lim\_)([^a-zA-Z\_])/$1\\$2$3/g;
	s/^ //;	s/ $//;
}

#--- α→$\alpha$と変換する, 000506e,000801f
sub	LaTeXmoji_with_dollar{
	my	($i,$d,$ptn);

	chop;	$_=$_." ";

	if( $H_eibun ){#000707n
		$ptn = ' 	\\\{\}\(\)\[\]｛｝\-\+\_\^\$';
		s/(\\limits)([$ptn])/$1$2/g;
		s/(\\limits)/$1 /g;

		for($i=0;$i<=$#def_txt_hensuu;$i++ ){
			s/$def_txt_hensuu[$i]([$ptn])/$def_tex_hensuu[$i]$1/g;
			s/$def_txt_hensuu[$i]/$def_tex_hensuu[$i] /g;
		}
		for($i=0;$i<=$#def_txt_moji;$i++ ){
			s/$def_txt_moji[$i]([$ptn])/$def_tex_moji[$i]$1/g;
			s/$def_txt_moji[$i]/$def_tex_moji[$i] /g;
		}

		# 980917 --- seisin が sei\sin にならないように変更 000422a
		s/(\W)(Cos|cos|COS)(\W)/$1\\cos $3/g;
		s/(\W)(Sin|sin|SIN)(\W)/$1\\sin $3/g;
		s/(\W)(Tan|tan|TAN)(\W)/$1\\tan $3/g;
		s/(\W)(Atan|ATan|atan|ATAN|Arctan|arctan|ARCTAN)(\W)/$1\\tan\^{-1}$3/g;
		s/(\W)(Exp|exp|EXP)(\W)/$1\\exp $3/g;
		s/(\W)(lim\_)(\W)/$1\\$2$3/g;	# LaTeX, TeX削除000601c
	

		s/・・・([$ptn])/\\cdots$1/g;			s/・・・/\\cdots /g;
		s/．．．([$ptn])/\\ldots$1/g;			s/．．．/\\ldots /g;
		s/\.\.\.([$ptn])/\\ldots$1/g;			s/\.\.\./\\ldots /g;
		s/\+\-([$ptn])/\\pm$1/g;				s/\+\-/\\pm /g;
		s/\-\+([$ptn])/\\mp$1/g;				s/\-\+/\\mp /g;
		s/←→([$ptn])/\\Leftrightarrow$1/g;	s/←→/\\Leftrightarrow /g;
		s/↑↓([$ptn])/\\Updownarrow$1/g;		s/↑↓/\\Updownarrow /g;
		s/↓↑([$ptn])/\\Updownarrow$1/g;		s/↓↑/\\Updownarrow /g;
  	}else{
		$d='$';
		s/(\\limits)/$d$1$d/g;

		for($i=0;$i<=$#def_txt_hensuu;$i++ ){
			s/$def_txt_hensuu[$i]/$d$def_tex_hensuu[$i]$d/g;
		}
		for($i=0;$i<=$#def_txt_moji;$i++ ){
			s/$def_txt_moji[$i]/$d$def_tex_moji[$i]$d/g;
		}

		# 980917 --- seisin が sei\sin にならないように変更 000422a
		s/(\W)(Cos|cos|COS)(\W)/$1$d\\cos $d$3/g;
		s/(\W)(Sin|sin|SIN)(\W)/$1$d\\sin $d$3/g;
		s/(\W)(Tan|tan|TAN)(\W)/$1$d\\tan $d$3/g;
		s/(\W)(Atan|ATan|atan|ATAN|Arctan|arctan|ARCTAN)(\W)/$1$d\\tan\^{-1}$d$3/g;
		s/(\W)(Exp|exp|EXP)(\W)/$1$d\\exp $d$3/g;
		s/(\W)(lim\_)(\W)/$1$d\\$2$d$3/g;	# LaTeX, TeX削除000601c
	

		s/・・・/$d\\cdots$d$1/g;
		s/．．．/$d\\ldots$d$1/g;
		s/\.\.\./$d\\ldots$d$1/g;
		s/\+\-/$d\\pm$d$1/g;
		s/\-\+/$d\\mp$d$1/g;
		s/←→/$d\\Leftrightarrow$d$1/g;
		s/↑↓/$d\\Updownarrow$d$1/g;
		s/↓↑/$d\\Updownarrow$d$1/g;
	}

	s/ $//;	$_=$_."\n";

	# &abs_norm;

	# ●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ → Warningする, 981121d, begin
	if( /(・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|①|②|③|④|⑤|⑥|⑦|⑧|⑨|⑩|⑪|⑫|⑬|⑭|⑮|⑯|⑰|⑱|⑲|⑳|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|≡|・ｽ・ｽ|∫|∮|√|⊥|∠|∟|⊿|∵|∩|∪|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|・|遑ポ遑楯遑ｨ|・弓博|遖ｱ|箞|遽慾邁－ｶ｡|邊ｼ|邉怖・|・|・|・|・)/ ){ # unixで表示できない外字一覧

		&print_warning('% txt2tex Warning('.$LineNum.'):外字"'.$1.'"は表示と印刷ができないかも？'."\n");
		&insrt_matoato_warning($LineNum,'外字"'.$1.'"は表示と印刷ができないかも？');
	}
	# ●・は表示(mac:ok,unix:NG,dos:?)、印刷(mac:?,unix:?,dos:NG)できないかも？ → Warningする, 981121d, end
}

# 絶対値、ノルムの LaTeX への変換
#   数式	：txtの書き方	：LaTeX
#   絶対値	：｜x｜		：  |x|
#   ノルム	：∥x∥		： \|x\|
#   1ノルム	：∥x∥1	： \|x\|_1
#   2ノルム	：∥x∥2	： \|x\|_2
#   ∞ノルム：∥x∥∞	： \|x\|_\infty
#	980917
#	●abs,norm,行列関連： ||a||∞が行列の中にあると、行列の | と区別できない
#		→ ||a||∞ の書き方を∥a∥∞に変更, 990102f
sub	abs_norm{
	#    ｜xa｜   xz   ∥x∥   a   ||xz||1   xa   ||２xz||∞   xa
	#if(/｜/){print;}
	#980920
	#	s/\|\|１/\|\|1/g;
	#	s/\|\|２/\|\|2/g;
	#
	#	s/｜\$*([a-zA-Z0-9\+\-\/\*\\\,\'\_\{\}\[\]\(\)（）｛｝ 	\^]*)\$*｜/\\left \|$1\\right \| /g;
	while(/^([^｜]*)｜([^｜]*)｜/){#110726a
		s/^([^｜]*)｜([^｜]*)｜/$1 \\left \| $2 \\right \| /g;
		s/\\right \| (1|2|１|２|\\infty|∞)/\\right \|\_$1 /g;
	}
	# 990102f, begin
	#	s/∥\$*([a-zA-Z0-9\+\-\/\*\\\,\'\_\{\}\[\]\(\)（）｛｝ 	\^]*)\$*∥(1|2|１|２|\\infty)/\\left \\\|$1\\right \\\|\_$2 /g;
	#	s/∥\$*([a-zA-Z0-9\+\-\/\*\\\,\'\_\{\}\[\]\(\)（）｛｝ 	\^]*)\$*∥/\\left \\\|$1\\right \\\| /g;
	while(/^([^∥]*)∥([^∥]*)∥/){#110726a
		s/^([^∥]*)∥([^∥]*)∥/$1 \\left \\\| $2 \\right \\\| /g;
		s/\\right \\\| (1|2|１|２|\\infty|∞)/\\right \\\|\_$1 /g;
	# print "---".$1." (1)\n";
	# print "---".$2." (2)\n";
	}
	# 990102f, end

	#	s/｛/\{/g;	# 981210b 000213b comment
	#	s/｝/\}/g;	# 981210b 000213b comment
}
#------ 全角文字のLaTeX文字への置換えの処理(end) ---------



#	●全角英数字を半角英数字に変換する(&ZenA_Z0_9toHan追加), 981123c, begin
sub	ZenA_Z0_9toHan{
	# 981125 s/^([ 	　]*$H_LineNum)//;	$tmp = $1;
	if( s/^([ 	　]*)($H_LineNum)// ){	# 981125
		$tmp = $1.$2;
	}else{
		$tmp = '';	
	}
	y/Ａ-Ｚａ-ｚ０-９/A-Za-z0-9/;
	$_ = $tmp.$_;
}
#	●全角英数字を半角英数字に変換する(&ZenA_Z0_9toHan追加), 981123c, begin



#------ √{a b}を{√{a b}}と中かっこで囲む処理(begin) , 全面改定 あのにゃん , 入れ子に未対応→後ろから変換すればいいかも---------, 981210a
sub root{
	if( s/[√√]/√/g ){
		# while(/√/){
		&getLineNum;
		chop;	$new_='';	$f = 0;
		while( s/^.// ){
			if(		$f==2 ){
				if(    $& eq "\}" ){	$n--;}
				elsif( $& eq "\{" ){	$n++;}
				if( $n==0 ){	$f = 0;	$new_ = $new_."\}\}";	next;}
			}elsif( $f==3 ){
				if(    $& eq "\]" ){	$n--;}
				elsif( $& eq "\[" ){	$n++;}
				if( $n==0 ){	$f = 0;	$new_ = $new_."\}\}";	next;}
			}elsif( $f==4 ){
				if(    $& eq "\)" ){	$n--;}
				elsif( $& eq "\(" ){	$n++;}
				if( $n==0 ){	$f = 0;	$new_ = $new_."\}\}";	next;}
			}
			if( $& eq "√" ){
				$new_ = $new_."\{".$&;
				s/^[ 	　]*//;		# √  {aa} → √{aa}  空白を削除

				$n = 1;

				s/^.//;
				if(    $& eq "\{" ){	$f = 2;	$new_ = $new_."\{";}
				elsif( $& eq "\[" ){	$f = 3;	$new_ = $new_."\{";}
				elsif( $& eq "\(" ){	$f = 4;	$new_ = $new_."\{";}
				else{
					&print_warning("% txt2tex Warning(".$LineNum."): √の後に { か ( か [ がありません"."\n");
					&insrt_matoato_warning($LineNum,'√の後に { か ( か [ がありません');
					$new_ = $new_."\{".$&;
					s/([\\]*[a-zA-Z0-9$def_txt_hensuuAll\.\_\^\!]*)//;
					$new_ = $new_.$&."\}\}";
				}
				next;
			}
			$new_ = $new_.$&;
		}
		$_ = $new_."\n";
	#   }# end while(/√/)
	}
}
#------ √{a b}を{√{a b}}と中かっこで囲む処理(end) ---------

#------ 空行に % を付ける begin 000211a ---------
sub	rm_kuugyou{
		s/^($H_LineNum)$/$1\%/;
}
#------ 空行に % を付ける end ---------

#------ ignor /*1*/ を，行にない全角数字１に置き換える処理(begin) ---------
sub	replIgnor{
	$NreplIgnor = 0;
	$tmp = 0;
	while( /\/\*([0-9]*)\*\// ){
		$ptnReplIgnorOrg[$NreplIgnor] = $1;
		while( /$tmp/ ){
			$tmp++;
		} 
		$ptnReplIgnorTmp[$NreplIgnor] = $tmp;
		s/\/\*([0-9]*)\*\//$tmp/;
		# 980920		s/\/\*([0-9]*)\*\//●$tmp●/;
		$NreplIgnor += 1;
	}
	# if($NreplIgnor){print;}
}
#------ ignor /*1*/ を，行にない数字 1 に置き換える処理(end) ---------

#------ ignor /*1*/ を，行にない数字 1 に置き換える処理を元に戻す処理(begin) ---------
sub	unreplIgnor{
	# print OUT $NreplIgnor;
	# for( $i=0;$i<$NreplIgnor;$i++ ){	#, 980918: =0 のとき同じ行に複数あるとバグする

	for( $i=$NreplIgnor-1;$i>=0;$i-- ){
		$ptn1 = $ptnReplIgnorOrg[$i];
		$ptn0 = $ptnReplIgnorTmp[$i];
		s/$ptn0/\/\*$ptn1\*\//;
		# 980920 s/●$ptn0●/\/\*$ptn1\*\//;
		# print $ptn0."	".$ptn1."\n";
		# print;
	}
	# if($NreplIgnor){print;}
}
#------ ignor /*1*/ を，行にない数字 1 に置き換える処理を元に戻す処理(end) ---------



#------------------------------------
#	(a+b)/(c+d)をfrac{a+b}{c+d}にする処理(begin)
#  例題は、tilde_tyuukakko参照
#------------------------------------
#初期設定

#	&define_LaTeXmoji;
sub frac{	#000422b, 完全書き直し
	my	($tmp1, $bef, $aft, $slash, $_tmp, $tmp_LineNum, $ptn_eq_den, $num, $den, $den2);	# $ptn_eq is global

	chop;						# \n削除

	if( s/^[ 	　]*($H_LineNum)[ 	　]*// ){	$tmp_LineNum = $&;}	#行番号12Ｃを仮除去 perl580bug
	else{										$tmp_LineNum = '';}
	$ptn_eq = $def_txt_hensuuAll.'a-zA-Z0-9\\\.\_\^\!＾\~￣…・｜';		# fracの中に入る文字,000707k,110810c
	$ptn_eq_den = $ptn_eq.'∂∇√∫∬';								# fracのdenの中に入る文字,000707k,000718a
	while(1){
		$den='';	$den2='';
		# a/b のとき
		if( s/([$ptn_eq]+)[ 	]*\/[ 	]*([$ptn_eq_den]+)(.*)// ){
			$num = "\\frac\{".$1."\}";	$den="\{".$2;
			$aft = $3;	$_tmp = $_;	$_ = $aft;
			if( !(s/^([\(\{\[｛])//) ){	
				$den=$den.'}';
			# a/b(t) のとき
			}else{
				$den2=&frac_get_den($1,$_,0);
			}
		# (1+a)/b, a(t)/b のとき
		}elsif( s/([$ptn_eq][\)\}\]｝]*)[ 	]*([\)\}\]｝])[ 	]*\/[ 	]*([$ptn_eq_den]+)(.*)/$1/ ){
			$den = '}{'.$3;	$aft = $4;	$num=&frac_get_num($2);	$_tmp=$_;	$_=$aft;
			if( !(s/^([\(\{\[｛])//) ){
				$den=$den.'}';
			# (1+a)/b(t), a(t)/b(t) のとき
			}else{
				$den2=&frac_get_den($1,$_,0);
			}
		# a/(b のとき
		}elsif( s/([$ptn_eq]+)[	 ]*\/[ 	]*([\(\{\[｛])[ 	]*([\(\{\[｛]*[$ptn_eq_den].*)// ){
			$_tmp=$_;	$num="\\frac\{".$1."\}\{";
			$den2=&frac_get_den($2,$3,1);
		# (1+a)/(b+1), a(t)/(b+1) のとき
		}elsif( s/([$ptn_eq][\)\}\]｝]*)[ 	]*([\)\}\]｝])[ 	]*\/[ 	]*([\(\{\[｛])[ 	]*([\(\{\[｛]*[$ptn_eq_den].*)/$1/ ){
			$tmp1 = $3;	$aft = $4;	$num=&frac_get_num($2);	$num=$num.'}{';	$_tmp=$_;
			$den2=&frac_get_den($tmp1,$aft,1);
		# 分数でないとき while 抜ける
		}else{	
		last;
		}

		if($_tmp=~/\([ 	]*$/ && $_=~/[ 	]*\)/ ||	# ({\frac{a}{b}}) -> (\frac{a}{b})と不要な{...}をつけない000801v
			$_tmp=~/\{[ 	]*$/ && $_=~/[ 	]*\}/ ||
			$_tmp=~/\[[ 	]*$/ && $_=~/[ 	]*\]/ ||
			$_tmp=~/｛[ 	]*$/ && $_=~/[ 	]*｝/ ){
			$_ = $_tmp.$num.$den.$den2.$_;
		}else{
			$_ = $_tmp.'{'.$num.$den.$den2.'}'.$_;
		}
	}
	$_ = $tmp_LineNum.$_."\n";
}

sub frac_get_num{
	my ($right, $num, $n, $tmp);

	$right = $_[0];
	$_ = $_.$right;	$num = &get_kakko_nakami_RtoL;	$tmp=$_;	$_=$num;	$n=s/[$right]//g;	$_=$tmp;

	if( length($num)>1 ){
		if( !(/$ptn_eq[ 	]$/) ){		# a(t)/b など \frac{a(t)}{b} とするとき(スペースがないとき)
			# if( s/[$ptn_eq]+[ 	]*$// ){	$num = $&.$num;}
			if( s/[$ptn_eq]+$// ){	$num = $&.$num;}	#000519b
			# else{	$tmp = $_;	$_ = $num;	if( $n==1 ){	s/^.//;	s/.$//;}	$num = $_;	$_ = $tmp;}
			else{	$tmp = $_;	$_ = $num;	if( $n>=1 ){	s/^.//;	s/.$//;}	$num = $_;	$_ = $tmp;}
			# print $n."  ".$num."111\n";
		}else{
			$tmp = $_;	$_ = $num;	if( $n==1 ){	s/^.//;	s/.$//;}	$num = $_;	$_ = $tmp;
		}
	}else{
		&print_warning("txt2tex warning: 000422b\-3\n");
		&insrt_matoato_warning($LineNum,'000422b\-3');
		$num = $_;
	}
	return "\\frac\{".$num;
}

sub	frac_get_den{
	my ($left, $den, $n, $tmp, $f_rmkakko);

	$left = $_[0];	$_ = $_[1];	$f_rmkakko = $_[2];
	$_ = $left.$_;	$den = &get_kakko_nakami_LtoR('');

	if( $f_rmkakko ){	$tmp = $_;	$_ = $den;	s/^.//;	s/.$//;	$den = $_;	$_ = $tmp;}

	return $den.'}';
}
#------------------------------------
#	(a+b)/(c+d)をfrac{a+b}{c+d}にする処理(end)
#------------------------------------




#------------------------------------
#	表をTeXに変換する処理(tbl2tex)(begin)
#●書き方, 000212a
#	表：						... \begin{table*}が付かないで、\begin{tabular}のみ, 000504g
#		or
#	表：キャプション			... 参照は、（表：キャプション）
#		or
#	表：キャプション（ラベル）	... 参照は、（表：ラベル）
#		or
#	表：キャプション（ラベル,上下ここ頁,中左右） ... キャプション省略時\begin{figure}[t]なし, 000505b
#------------------------------------
#初期設定(tbl2tex)
sub	init_tbl{
	$fHyou=0;
	# $nHyou=1;	# 000430コメント化
	$nHyou=0;
	# @tbl_moji_yose= cllrr	#000505b
}

#------ tbl2tex の処理(begin) ---------
sub tbl{
	my	($_tmp, @tmp, $format, $i);	# $hyouTmp, $f_tablelessをローカル変数にするとダメ000504g
	my	($n_tate_left, $n_tate_right, $tmp0);	#000504i
	my	($position, $_tmp0, $tmp1, $j);	#000505b

	if( s/^	[	　]*($H_LineNum)表：([ 	　]*)// ){
		$LineNum = $1;
		$f_tableless=0;	if( length($2)==0 ){	$f_tableless=1;}	#表：の後空白がないとき

		# default
		$position='tbh';
		@tbl_moji_yose=//;	$tbl_moji_yose[0]='c';	$tbl_moji_yose[1]='l';

		if( s/^(.*)（[ 	　]*(.*)[ 	　]*）[ 	　]*\n/$2/ ){
			if( !($f_tableless==1 && length($1)==0) ){	#キャプションがあるとき
				$captionTbl[$nHyou] = $1;	$f_tableless=0;
				koko # なにこれ 200624
			}

			# $_tmp0=$_;	$tmp1='[ 	]*([上下こ頁 ]+)[ 	]*';	# $positionの設定
			$_tmp0=$_;	$tmp1='[ 	]*([!上下こ頁 ]+)[ 	]*';	# $positionの設定 220101

			if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){
				$_tmp=$_;	$_=$1;	y/上下頁/tbp/;	s/ここ/h/;
				if( length($_tmp)==0 || /こ/ ){	$_=$_tmp0;}	# （）の中身がなくなったらラベルとみなす
				else{							$position=$_;	$_=$_tmp;}
			}elsif(/\,[ 　	]*\,/){	# if 	表：あああ（abc,,右左中６） then ,, -> , to avoid "abc,"
				s/\,[ 　	]*\,/\,/;
			}

			$_tmp0=$_;	$tmp1="[ 	]*(\\\\.+)[ 	]*";	# $sizeの設定(仮)
			if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){
				$tabsize = $1;
			}else{
				$tabsize = '\\normalsize';
			}

			# @tbl_moji_yoseの設定（もしラベルがなければ（$_に,が含まれなければ）、ラベルとみなす。）
			if( !(/\,/) ){
				s/^[ 	]*//;	s/[ 	]*$//;	$tblLabel[$nHyou] = &repl_label_moji($_);
			}else{
				$_tmp0=$_;	$tmp1='[ 	]*([中左右1-9１-９ ]+)[ 	]*';	# @tbl_moji_yoseの設定

				if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){	# 中左右がある
					$_tmp=$_;	$_=$1;	y/中左右123456789１２３４５６７８９/clr123456789123456789/;
					$i=0;	while( s/^.// ){	$tbl_moji_yose[$i] = $&;	if($tbl_moji_yose[$i]=~/[1-9]/){$tbl_moji_yose[$i]='p{'.$tbl_moji_yose[$i].'em}';}	$i++;}
					$_=$_tmp;
					if($i==1){	$tbl_moji_yose[1]=$tbl_moji_yose[0];}#配列の大きさ・要素数は@hairetu = $#hairetu+1, 110810a
				}
				s/^[ 	]*//;	s/[ 	]*$//;	$tblLabel[$nHyou] = &repl_label_moji($_);
			}
			if( /\,/ ){
				$_tmp=$_;	$_=$_tmp0;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):表の参照ラベル名（'.$_tmp.'）に,が含まれます'."\n");
				&insrt_matoato_warning($LineNum,'表の参照ラベル名（'.$_tmp.'）に,が含まれます');
			}
		}else{	# （...）がないとき
			chop;	s/[ 	]*$//;
			if( $f_tableless==1 && length($_)==0 ){	$f_tableless=1;}	#キャプションがないとき000504g
			else{									$f_tableless=0;}
			if( $f_tableless==0 ){
				$captionTbl[$nHyou] = $_;
				$tblLabel[$nHyou] = "表：".&repl_label_moji($_);
			}
		}
		# print $captionTbl[$nHyou]." - ".$tblLabel[$nHyou]." - ".$position." - ";print @tbl_moji_yose;print " - ".$#tbl_moji_yose."\n";
		if( $f_tableless==0 ){	#000504g
			$_ = $captionTbl[$nHyou];	s/[ 	　]*$//o;	$captionTbl[$nHyou] = $_;
			$_ = $tblLabel[$nHyou];	s/\"//g;	s/[ 	　]*$//o;	$tblLabel[$nHyou] = $_;
			$H_OUT=$H_next."\\begin\{table\*\}\[".$position."\]\n";	&print_OUT_euc;	#980922 ２段組で１段のテーブル, 000504c"
			$H_OUT=$H_next."	\\centering\n";	&print_OUT_euc;
			$H_OUT=$LineNum.'"	\caption{"'.$captionTbl[$nHyou].'"}"'."\n";	&print_OUT_euc;
			$H_OUT=$LineNum.'"	\label{'.$tblLabel[$nHyou].'}"'."\n";	&print_OUT_euc;	#000212a
			$H_OUT=$LineNum."	".$tabsize."\n";	&print_OUT_euc;	# 200901
			$nHyou += 1;
		}else{
			if( length($tblLabel[$nHyou])>0 ){
				$H_OUT=$LineNum.'"	\label{'.$tblLabel[$nHyou].'}"'."\n";	&print_OUT_euc;	#000212a,110828a
				# $nHyou += 1;# labelを表番号に反映させない（表のキャプションも番号も表示されないので）
			}
		}
		$fHyou = 3;
		$hyouTmp = "";
		next;
	} elsif( $fHyou>0 ){
		if( /^	/o ){
			if(/図：（/){	#110810b
				for( $i=1;$i<=20;$i++ ){
					s/図：（([a-zA-Z0-9.]+),([0-9.]+)倍）/"\\includegraphics[width=$2\\hsize]{$1}\\label{$1}"/g;
					s/図：（([a-zA-Z0-9.]+)）/"\\includegraphics[width=1\\hsize]{$1}\\label{$1}"/g;
				}
			}
			s/　/  /g;	#000530i
			s/^	($H_LineNum)([\|]+)[ 	　]*/$2 $1/;	#000504i
			if( $fHyou==3 ){
				if( /(___|\-\-\-)/o ){	# 990102b
					$hyouTmp .= "		\\hline\n";
				}elsif( /===/o ){
					$hyouTmp .= "		\\hline \\hline\n";
				}elsif( /^[ 	]*($H_LineNum)[ 	]*\/\*[0-9]+\*\// ){	# 000212e % ... の行のとき print する

					if( $H_eibun==1){	s/｜/|/g;}	#000707l
					$H_OUT=$_;	&print_OUT_euc;
				}else{
					&getIgnor_double_quotation;	# 000212e
					s/^[ 	　]*//;
					$n_tate_left = 0;	while( s/^\|// ){	$n_tate_left++;}
					s/[ 	　]*$//;
					$n_tate_right = 0;	while( s/\|$// ){	$n_tate_right++;}
					s/\|/ \| /g;	s/\|  \|/ \|\| /g;
					s/\&/ \& /g;	# 000220a
					@tmp = split;
					# print @tmp;print "	".$#tmp."\n";
					#	|		1
					#	93Ｃ	2
					#	||		3
					#	c		4
					$format = '|' x $n_tate_left;
					# $format = $format."c";
					$format = $format.$tbl_moji_yose[0];	$j=1;	#000505b
					for( $i=1;$i<=$#tmp;$i++ ){
						if( $j<=$#tbl_moji_yose ){
							$tmp1 = $tbl_moji_yose[$j];
						}
						$j++;	#000505b
						# print $tmp[$i]."   ".$i."\n";
						if( $tmp[$i] eq '|' ){
							$format .= '|';
							$format .= $tmp1;
						}elsif( $tmp[$i] eq '||' ){
							$format .= '||';
							$format .= $tmp1;
						}elsif( $tmp[$i] eq '&' ){	# 000220a
							$format .= $tmp1;
						}
					}
					$tmp0 = '|' x $n_tate_right;
					$format = $format.$tmp0;
					# print $n_tate_left.$format.$n_tate_right."\n";
					if( $H_eibun==1){	$hyouTmp=~s/｜/|/g;	$format=~s/｜/|/g;}	#000707l
					if($f_bigtabular==1&&$f_tableless==1){
						$H_OUT=$H_next."	\\begin{Tabular}{".$format."}\n";	&print_OUT_euc;#110810e
					}else{
						$H_OUT=$H_next."	\\begin{tabular}{".$format."}\n";	&print_OUT_euc;}
					if( length($hyouTmp)>0 ){	$H_OUT=$H_next.$hyouTmp."\n";	&print_OUT_euc;}	#000212c
					# &getIgnor_double_quotation;	# 000212e
					s/^[ 	]*($H_LineNum)/	$1/g;
					# s/[\||\|\s]\n/ \\\\\n/g;
					s/\|*[ 	　]*\n/ \\\\\n/g;
					s/\|\|/ &	/g;
					s/\|/ &	/g;
					s/^([ 	]*)($H_LineNum)/$2$1/;	# 000212b
					if( $H_eibun==1){	s/｜/|/g;}	#000707l
					$H_OUT=$_;	&print_OUT_euc;
					$fHyou = 2;
				}
			}elsif( $fHyou==2 ){
				# if( /___/o ){
				if( /(___|\-\-\-)/o ){	# 990102b
					$H_OUT=$H_next."		\\hline\n";	&print_OUT_euc;
				}elsif( /===/o ){
					$H_OUT=$H_next."		\\hline \\hline\n";	&print_OUT_euc;
				}elsif( /^[ 	]*($H_LineNum)[ 	]*\/\*[0-9]+\*\// ){	# 000212e % ... の行のとき print する

					$H_OUT=$_;	&print_OUT_euc;
				}else{
					&getIgnor_double_quotation;	# 000212e
					s/^[ 	　]*[\|]+/	/g;
					# s/[\||\|\s]\n/ \\\\\n/g;
					s/\|*[ 	　]*\n/ \\\\\n/g;	#000504i
					s/\|\|/ &	/g;
					s/\|/ &	/g;
					s/^([ 	]*)($H_LineNum)/$2$1/;	# 000212b
					if( $H_eibun==1){	s/｜/|/g;}	#000707l
					$H_OUT=$_;	&print_OUT_euc;
				}
			}
			next;
		}else{
			if($f_bigtabular==1&&$f_tableless==1){
					$H_OUT=$H_next."	\\end{Tabular}\n";	&print_OUT_euc;#110810e
			}else{	$H_OUT=$H_next."	\\end{tabular}\n";	&print_OUT_euc;}
			if( $f_tableless==0 ){	$H_OUT=$H_next."\\end{table*}\n";	&print_OUT_euc;}	#980922 ２段組で１段のテーブル, 000504g
			$fHyou = 0;
			# このあと別の処理
		}
	}
}
#------ tbl2tex の処理(end) ---------

# 表番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelTbl{
	print LABEL encode("utf8","	表番号の参照ラベル一覧\n");
	for($i=0;$i<$nHyou;$i++){
		# 000212a print LABEL $captionTbl[$i]."\n";
		print LABEL encode("utf8",$tblLabel[$i]."\n");	#000212a
	}
}
# 表番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(end)

#------------------------------------
#	表をTeXに変換する処理(tbl2tex)(end)
#------------------------------------




#------------------------------------
#	改行のみの行を削除(begin)
#------------------------------------
sub omitOnlyKaigyou{
	$tmp = $_;
	s/^[ 	　]*($H_LineNum)//g;
	if( ($fYouyaku==0) && ($_ eq "\n") ){
		next;
	}
	$_ = $tmp;
}
#------------------------------------
#	改行のみの行を削除(end)
#------------------------------------





#------------------------------------
#	式の行（先頭にタブ）をTeXに変換する処理(eqn2tex)(begin)
#------------------------------------
#初期設定(eqn2tex)
sub	init_eqn2tex{
	#---------------------------
	#	$eqn		#: 行列の式１つ分と、その次にスカラ式のときそのスカラ式
	$nEq = 0;	#: $eqnのインデックス ... $eqn[$nEq]
	#	M =（行列1）+（行列2）
	#	a = b
	#---------------------------
	@eq ="";	#: eqnarray環境１つ分全部の行, $eq[$i]は1行文の式
	$iEq=0;		#: $eqのインデックス ... $eq[$iEq]
	#	M =
	#	\begin{array}
	#		行列1
	#	\end{array}
	#	+
	#	\begin{array}
	#		行列2
	#	\end{array}
	#	a = b
	#---------------------------
	$numEq = 0;	#: （ラベル）のインデックス：eqLabel[$numEq]
	$fEq = 0;	#: 行列のときまたはそのあとにスカラ式がある場合1
	$fEqMat =0;	#: 1:行列、0:スカラの式
	$rawEq = 0;	#: 行列の行数

	#	$fEq2 = 0;	#: 式のタブのとき1 ← 不要のようだ000227a
	#	$fMatTyuuKakko : 行列の左カッコを { にするフラグ
	$fMatDoubleLineNum=0;	#981119d, 1/3
	$fMatKaigyou=0;	#000527d新機能: 行列の改行 M=[... \n ...] を書けるようにする

}


#------ eqn2tex の処理(begin) ---------
sub eqn{
	my	($iii0, $iii);
	my	($i, $j, $tmp_, $fMatNoLeft);
	$iii0=0;#1002
	if( /^	/o && !(/表：/o || /図：/o || /縦：/o || /横：/o || /複：/o) && $fHyou==0){ # 式の抽出
		#1
		if( /^	[ 	]*($H_LineNum)\n/ ){	next;}	#000506a
		# &eqn_in_mbox_dollar;	#	◯txt2tex:debug: 式の中の\mbox{...}の中を dollar 処理する, 000625m
		&getIgnor_double_quotation;	# 000428b
		# $fEq2 = 1;
		if( $fMatKaigyou ){	#000527d
			if( (tr/／//) < (tr/＼//) ){	s/^(	[ 	]*)($H_LineNum)/$1$2／/;}
			elsif( (tr/／//) > (tr/＼//) ){	s/^(	[ 	]*)($H_LineNum)/$1$2＼/;}
			elsif( ($i=(tr/\|//))>0 ){	while($i>2){	$i-=2;}
			if($i==1){					s/^(	[ 	]*)($H_LineNum)/$1$2\|/;}
			}
		}
		# print "$fMatKaigyou $i $_";
		if( /[／\|＼]/o || $fEq>0){	# 行列の式またはそのあとにスカラ式がある場合

			#2
			$iii0++;if($iii0>100){print "エラー001";last;}	# 無限ループ回避策#1002
			if( $nEq==0 ){								# はじめての行のとき eqn 初期化
				@eqn="";
			}
			if( (/[／\|＼\=a-zA-Z0-9]/o) || ($nEq>0) ){	#　行列の抽出
				#3
				s/^[ 	　]*//g;							# 先頭の空文字削除

				s/[ 	]*／[ 	]*/／/g;					# 行列のかっこ前後の空文字削除

				s/[ 	]*\|[ 	]*/\|/g;					# 行列のかっこ前後の空文字削除

				s/[ 	]*＼[ 	]*/＼/g;					# 行列のかっこ前後の空文字削除

				if( /[／\|＼]/o) {						#　行列の抽出
					&putMatLineNum;							# 行列の行番号を入れる

				}
				if( /^[^／\|＼]*／/ ){	#行列の第1行目（はじまり）のとき
					&get_eqn_array_option('');	#$eqn_array_kakko_rightなど初期化000506b
				}
				if( s/[ 	　]*（([^）]*)）\n/\n/ ){			# 行列の式ラベルの抽出とラベル" （label）"の削除, なんでも許す990102d
					$tmp_ = &get_eqn_array_option($1);	#000506b
					if( length($tmp_)>0 ){	# 000218a
						if( $tmp_ eq "欠番：" ){	$eqLabel=0;}	#000527b
						else{	$eqLabel[$numEq] = &repl_label_moji($tmp_);	$numEq++;	$eqLabel=1;}
						# print "1:  ".&repl_label_moji($tmp_)."\n";
					}else{
						$eqLabel=2;
					}
				}
				$eqn[$nEq] = $_;	$nEq++;					# eqn に行をためる

			}
			if( (/[／＼]/ && !(/\|/) && $nEq>1) || $fEq>0 ){ # txtの行列の式の部分のeqnへの代入が終了したときの処理
				#3
				# print "BEGIN\n";print @eqn;print "END\n";
				# ／の数が１で＼の数が０のとき行列の左カッコを { にする(begin) 981004
				$tmp_ = $_;	$_ = $eqn[0];
				if( tr/／//==1 && tr/＼//==0 ){
					$fMatTyuuKakko = 1;
					# print "$eqn_array_kakko_right $eqn_array_kakko_left 00000\n";
					if( $eqn_array_kakko_left eq '.' ){	#000527d
						$eqn_array_kakko_left = "\\\{";	$eqn_array_kakko_right = "\\\}";	# デフォルト（右カッコのみの行列）,000527d
					}else{
						$fMatKaigyou=1;
					}
				}else{
					$fMatTyuuKakko = 0;
					if( $eqn_array_kakko_left eq '.' ){	#000527d
						$eqn_array_kakko_left = '[';	$eqn_array_kakko_right = ']';		# デフォルト
					}
					if( $fMatKaigyou==1 ){	$eqn_array_kakko_left='.';	$fMatKaigyou=0;}	#000527d
				}
				# print "($fMatKaigyou)$_\n";
				$_ = $tmp_;
				# ／の数が１で＼の数が０のとき行列の左カッコを { にする(end) 981004
				$iii=0;
				$fMatNoLeft=0;	#1行に複数の行列があるとき一番左の行列の左カッコを削除したら1,000527d
				while( $#eqn>0 ){
					$iii++;if($iii>1000){print '('.$LineNum.')'."エラー000  \"".$eqn[0].$eqn[1]."\"\n";last;}	# 無限ループ回避策

					#---- 行列を含む式の処理の終了条件

					$tmp = 1;						# eqnが空白行のみのとき tmp=1, else tmp=0
					for( $i=0;$i<$nEq;$i++){
						$_ = $eqn[$i];
						if( !(/^[ 	　]*\n/o) ){
							$tmp = 0;
						}
					}
					if( $tmp == 1 ){				# eqnが空白行だけのとき
						$fEq = 0;	#必ず必要			# 変数初期化
						$fEqMat = 0;
						$rawEq = 0;
						$nEq = 0;
						@eqn = "";
						# $eq[$iEq] .= "ラベルの式？ ";	# ラベルの式, 980911
						$eq[$iEq] .= "\n";	# 980911	# ラベルがあれば \label を書く
						if( $eqLabel==1 ){
							$eq[$iEq] .= $H_next."		\\label{".$eqLabel[$numEq-1]."}";
						}elsif( $eqLabel==2 ){	# 000218a
							$eq[$iEq] .= $H_next;
						}else{
							$eq[$iEq] .= $H_next."		\\nonumber";
						}
						$eqLabel = 0;
						$iEq++;
						last;							# whileループを抜ける

					}
					#-----　行列の中身をかく					# eqnが空白行だけでないとき
					@tmp1='';
					$_ = $eqn[0];
					if( /改行：/o ){
						#未完成 &eqnMatKaigyou; # 行列の 中身）の中身をeqに代入(改行：があるとき), eqn→tmp1
						&getMatNakami;	#まだ未完成なのでこれで代用
					}else{
						&getMatNakami;					# 行列の 中身）の中身をeqに代入(改行：がないとき), eqn→tmp1
					}
					if( $rawEq == 0 ){					# 行列の行数が０？
						$tmp1[$i] .= "\n";
					}elsif( $fEqMat==1 ){			# 行列のとき \end{array} \right] を書く
						if( $fMatNoRight == 1 ){		# 行列の右括弧がないとき
							$tmp1[$i] .= "\n".$H_next."		\\end{array} \\right\.\n";
						}else{					# 行列の右括弧があるとき
							# $tmp1[$i] .= "\n".$H_next."		\\end{array} \\right\]\n";
							$tmp1[$i] .= "\n".$H_next."		\\end{array} \\right".$eqn_array_kakko_right."\n";	#000506b
							# print $eqn_array_kakko_right."\n";
						}
					}
					for( $j=0;$j<=$i;$j++){			# eq に変更した内容を代入
						if( $tmp1[$j] ne "" && $tmp1[$j] ne "\n" ){
							# print $j."--- ".$tmp1[$j]."XXX\n";
							#---------------981119d 2/2, begin
							# ^14Ｃかつ\nなしの行のあと、^15Ｃの行が続くとバグが発生する

							# → この条件のとき ^15Ｃを削除する

							$_ = $tmp1[$j];
							if( $fMatDoubleLineNum==1 ){
								if( !(s/^($H_LineNum)// && !(/\n$/)) ){
									$fMatDoubleLineNum=0;
								}
							}else{
								if( /^($H_LineNum)/ && !(/\n$/) ){
									$fMatDoubleLineNum=1;
								}
							}
							$tmp1[$j] = $_;
							#---------------981119d 2/2, end
							$eq[$iEq] .= "	".$tmp1[$j];
						}
					}
					$fMatDoubleLineNum=0;	#981119d, 3/3
					#----　行列の始まりの処理 # \left[ \\begin{array}{ll} を書き、行列のときfEqmat=1にする

					$_ = $eqn[0];
					# print "$_\n";
					if( /^／/ ){
						if( s/＼.*$// ){	$fMatNoRight = 0;}
						else{				$fMatNoRight = 1;}	# 行列の右括弧がないときfMatNoRight=1
						$i = tr/\,// + 1;
						# $tmp = l x $i;
						$tmp='';	for( $j=0;$j<=$#eqn_array_moji_yose;$j++){	$tmp=$tmp.$eqn_array_moji_yose[$j];}	$tmp = $tmp.($eqn_array_moji_yose[$j-1] x ($i-$j));	#000527d
						if( $eqn_array_kakko_left eq '.' ){	#000527d
							if($fMatNoLeft==0){	$fMatNoLeft=1;}
							else{	$eqn_array_kakko_left='[';}
						}
						$eq[$iEq] .= "\n".$H_next.'		\left'.$eqn_array_kakko_left.' \begin{array}{'.$tmp."\}\n";	#000506b,000527d
						$fEqMat = 1;	# matrix
					}else{
						$fEqMat = 0;	# schaler
					}
					# print $eqn_array_kakko_left." - ".$eq[$iEq]."YYY\n";
					#----　行列の（を削除 # 行列の（中身 の（を削除、行列の行数rawEqをカウント
					$rawEq = 0;
					$_ = $eqn[0];
					if( s/^／[ 	　]*// ){
						$eqn[0] = $_;
						for( $i=1;$i<$nEq;$i++){
							$_ = $eqn[$i];
							if( s/^＼// ){
								$eqn[$i] = $_;
								$rawEq = $i;
								last;
							}elsif( s/^\|[ 	　]*// ){
								$eqn[$i] = $_;
							}elsif( s/^／[ 	　]*// ){	# 000227a
								&getLineNum;#	s/$H_LineNum//g;
								&print_warning("% txt2tex Error\(".$LineNum."\)\:行列の左カッコの下を＼にしてください\n".$H_next."	".$_);
								&insrt_matoato_warning($LineNum,'行列の左カッコの下を＼にしてください');
								$eqn[$i] = $_;
								$rawEq = $i;
								last;
							}
						}
					}
					$fEq = 1; #: 行列のときまたはそのあとにスカラ式がある場合1
					#----　行列の）を削除 # 行列の ）+...の）を削除

					$_ = $eqn[0];
					if( s/^＼[ 	　]*// ){
						$eqn[0] = $_;
						for( $i=1;$i<$nEq;$i++){
							$_ = $eqn[$i];
							if( s/^／// ){
								$eqn[$i] = $_;
								last;
							}elsif( s/^[＼\|][ 	　]*// ){
								$eqn[$i] = $_;
							}elsif( s/^＼[ 	　]*// ){	# 000227a
								&getLineNum;#	s/$H_LineNum//g;
								&print_warning("% txt2tex Error\(".$LineNum."\)\:行列の右カッコの下を／にしてください\n".$H_next."	".$_);
								&insrt_matoato_warning($LineNum,'行列の右カッコの下を／にしてください');
								$eqn[$i] = $_;
								last;
							}
						}
					}
				} #end of while
				#3
			}
			#---------------------------------------
		}else{ # 行列の式またはそのあとにスカラ式がある場合以外（上の行も今の行もスカラ式のみ）
			#2
			#	●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a未 (begin)
			#	  → とりあえず Error を出すだけ
			if( $nEq != 0 ){
				$tmp_ = $_;
				$_='';	for($j=0;$j<$nEq;$j++){	$_.="	".$eqn[$j];}
				&getLineNum;	s/$H_LineNum//g;
				@eqn = '';	$nEq = 0;	$fEqMat = 0;	$rawEq = 0;
				$eq[$iEq] = $_;	$iEq++;
				&print_warning("% txt2tex Error\(".$LineNum."\)\:行列の変換に失敗! 書き方ミス?\n");
				&insrt_matoato_warning($LineNum,'行列の変換に失敗! 書き方ミス?');
				# s/\n/\n$H_next\%/g;	s/(.*)\n$H_nextComp\%$/$1\n/; # ??
				&print_warning('%'.$_);
				$_ = $tmp_;
			}
			#	●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a未 (end)
			s/^[ 	　]*//g;								# 先頭の空文字を削除

			$eq[$iEq] = "	";
			# if( s/[ 	　]*（([\w\:]*)）\n/\n/ ){			#　式ラベルの抽出とラベル" （label）"の削除, :を許す981101
			if( s/[ 	　]*（([^）]*)）\n/\n/ ){			#スカラの式ラベルの抽出とラベル" （label）"の削除, なんでも許す990102d
				$eqLabel[$numEq] = &repl_label_moji($1);	$numEq++;
				# if( !/\&/ ){	# 000219a
				if( !(/\&/)){ # 200624 debug未エラー出そう
					if( !(s/[ 	　]*([\=≡≠∝＝])[ 	　]*/	&$1& /) ){			# &=&, &:&, && をつける, 処理の順番を変更 981121b 000218b 000707j
						if( !(s/[ 	　]*([\>\<＜＞≧≦])[ 	　]*/	&$1& /) ){	# 000218b
							if( !(s/[ 	　]*\:[ 	　]*/	&\:& /) ){
								$eq[$iEq] .= "&& ";
							}
						}
					}
				}
				$eq[$iEq] .= $_;
				if( length($eqLabel[$numEq-1])>0 ){	# 000218a
					$eq[$iEq] .= $H_next."		\\label{".$eqLabel[$numEq-1]."}";
				}else{
					$numEq--;
					$eq[$iEq] .= $H_next;
				}
			}else{											# ラベル以外のとき，eqに行を代入
				# if( !/\&/ ){	# 000219a
				if(!(/\&/)){ # 200624 debug未エラー出そう
					if( !(s/[ 	　]*([\=≡≠∝＝])[ 	　]*/	&$1& /) ){			# &=&, &:&, && をつける, 処理の順番を変更 981121b 000218b
						if( !(s/[ 	　]*([\>\<＜＞≧≦])[ 	　]*/	&$1& /) ){	# 000218b
							if( !(s/[ 	　]*\:[ 	　]*/	&\:& /) ){
								$eq[$iEq] .= "&& ";
							}
						}
					}
				}
				$eq[$iEq] .= $_;
				$eq[$iEq] .= $H_next."		\\nonumber";
			}
			$iEq++;
		}
		next;
		#---------------------------------------
	}else{ # 式以外の抽出
		#1
		if( $iEq>0 ){		# eqに貯めておいた式を書き出す
			$tmp_ = $_;
			# open(AAA,">>iran.eq");
			# print AAA "\\begin{eqnarray}\n";
			$H_OUT=$H_next."\\begin{eqnarray}\n";	&print_OUT_euc;
			#	●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a未 (begin)
			#	  → とりあえず Error を出すだけ
			if( $nEq != 0 ){
				$_='';	for($j=0;$j<$nEq;$j++){	$_.="	".$eqn[$j];}
				&getLineNum;	s/$H_LineNum//g;
				&print_warning("% txt2tex Error\(".$LineNum."\)\:行列の変換に失敗! 書き方ミス?\n");
				&insrt_matoato_warning($LineNum,'行列の変換に失敗! 書き方ミス?');
				&print_warning('%'.$_);
				@eqn = '';	$nEq = 0;	$fEqMat = 0;	$rawEq = 0;
			}
			# ●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a未 (end)
			for($i=0;$i<$iEq;$i++){

				$eq[$i] = &eqnMatKakko($eq[$i]);
				if( length($eq[$i])>0 ){	$eq[$i] = &set_ampersand($eq[$i]);}	# 確実に = → &=&, 行列の,→& 新規作成000502b
				# print AAA $eq[$i];
				# if($eq[$i]=~/next/){print "----------\n".$eq[$i]."\n"."----------\n";}
				$H_OUT=$eq[$i];	&print_OUT_euc;
				if( $i<$iEq-1 ){
					if( $eq[$i]=~/label|nonumber/ ){	# 000218a
						$H_OUT=" \\\\";	&print_OUT_euc;
					}else{
						$H_OUT=	"		\\\\";	&print_OUT_euc;
					}
					# print AAA " \\\\";
				}
				$H_OUT="\n";	&print_OUT_euc;
				# print AAA "len=".length($eq[$i])."\n";
			}
			$H_OUT=$H_next."\\end{eqnarray}\n";	&print_OUT_euc;
			# print AAA "\\end{eqnarray}\n";
			# close(AAA);
			$_ = $tmp_;
		}
		@eq="";	$iEq=0;
		#1
	}
}

sub	ignor_mbox{	#	◯txt2tex:debug: \mbox{...}を ignor化, 000625n
	my	($_new, $_aft, $_new2, $_aft2, $_tmp);
	$_new='';	chop;
	while( s/\\mbox[ 	]*(\{.*)/\/\*$nIgnor\*\// ){
		$_new=$_new.$_;	$_=$1;	$nakami = &get_kakko_nakami_LtoR("quiet");
		$ptnIgnor[$nIgnor] = "\\mbox".$nakami;	$nIgnor++;
	}
	$_=$_new.$_."\n";
}

sub	eqn_in_mbox_dollar{	#	◯txt2tex:debug: 式の中の\mbox{...}の中を dollar 処理する, 000625m
	my	($_new, $_aft, $_new2, $_aft2, $_tmp);
	$_new='';	chop;
	while( s/\\mbox[ 	]*(\{.*)/\\mbox/ ){
		$_new=$_new.$_;	$_=$1;	$nakami = &get_kakko_nakami_LtoR("quiet");	$_aft=$_;
		$nakami=~s/^.//;	$_new=$_new.$&;	$nakami=~s/.$//;	$_aft=$&.$_aft;
		$_=$nakami.'""';
		$_new2='';
		while(s/(\"[^\"]*\")(.*)//){
			$_=$_."\n";	$_tmp=$1;	$_aft2=$2;
			#------ 文章の中の式の両サイドに$を挿入にする処理 ---------"
			&dollar2;
			chop;
			s/\$([ 	\,]*)\\(LaTeX2e|LaTeX|TeX)[ 	]*\$[ 	]*/$1\\$2 /g;	#000601c,000611a
			s/\$([ 	\,]*)\\(LaTeX2e|LaTeX|TeX)[ 	]*([\,])*\$[ 	]*/$1\\$2 $3 /g;	#000611a
			#	●debug: Ё, ё → $\$"${E}$, $\$"${e}$ →  \"{E}, \"{e}, $"$を"に変換する, 000501a,000625h
			s/\$([ 	,\"”]*)\$/$1/g;	# 000210f

			# Fig.とfig.とFigureとfigureの下付き処理と$の処理をしない981119c"
			s/\$(Fig|fig|Figure|figure|Table|table)([\. 0-9]*)\$/$1$2/g;
			$_new2 = $_new2.$_.$_tmp;	$_=$_aft2;
		}
		$_=$_new2.$_;	s/..$//;
		$_new = $_new.$_;	$_=$_aft;	}
	$_=$_new.$_."\n";
}

#	●行列の後ろに（ラベル,[中左左）が書かれているとき、\left[ \begin{array}[cll] とする, 000506b
# Usage: $label = &get_eqn_array_option($label);
# input: $_[0]=$label: （）の中身の"ラベル,[中左左"
# output: return $out=$label, @eqn_array_moji_yose, $eqn_array_kakko_left, $eqn_array_kakko_right
# called by &eqn, 
sub	get_eqn_array_option{
	my	($_org, $out);
	my	($_tmp0, $tmp1, $i);

	$_org = $_;	$_ = $_[0];

	# default
	@eqn_array_moji_yose=//;	$eqn_array_moji_yose[0]='l';
	# if( $fMatTyuuKakko ){
		# $eqn_array_kakko_left = "\\\{";	$eqn_array_kakko_right = "\\\}";	# デフォルト（右カッコのみの行列）,000527d
	# }else{
		# $eqn_array_kakko_left = '[';	$eqn_array_kakko_right = ']';		# デフォルト
	# }
	$eqn_array_kakko_left = '.';	$eqn_array_kakko_right = ']';

	# @eqn_array_moji_yoseの設定（もしラベルがなければ（$_に,が含まれなければ）、ラベルとみなす。）
	# if( /\,/ ){
	if( s/\,.*// ){
		$_tmp0=$_;	$_=$&;	$tmp1='[ 	]*([\(\)\[\]\{\}｛｝]*)[ 	]*([中左右 ]*)[ 	]*';	# @eqn_array_moji_yoseの設定

		# if( s/^$tmp1\,// || s/\,$tmp1$// ){	# 中左右がある

		if( s/\,$tmp1$// ){	# 中左右がある

			# print "$_ - $1 - $2 222222\n";
			$_tmp=$_;	$_=$1;	$tmp1=$2;
			while(length($_)>1){	s/.$//;}
			if(	   /(\[|\])/ ){	$eqn_array_kakko_left = '[';	$eqn_array_kakko_right = ']';}
			elsif( /(\(|\))/ ){	$eqn_array_kakko_left = '(';	$eqn_array_kakko_right = ')';}
			elsif( /(\{|\})/ ){	$eqn_array_kakko_left = "\\\{";	$eqn_array_kakko_right = "\\\}";}
			elsif(/(\｛|\｝)/){	$eqn_array_kakko_left = "\\\{";	$eqn_array_kakko_right = "\\\}";}
			$_=$tmp1;	s/ //g;	y/中左右/clr/;
			$i=0;	while( s/^.// ){	$eqn_array_moji_yose[$i] = $&;	$i++;}
			$_=$_tmp;
		}
		$_=$_tmp0;
		s/^[ 	]*//;	s/[ 	]*$//;
	}

	$out=$_;	$_ = $_org;
	# print "$eqn_array_kakko_left $out - $eqn_array_moji_yose[0] $eqn_array_kakko_right 1111\n";
	# print $out." - ".$eqn_array_kakko_left." - ";print @eqn_array_moji_yose;print " - ".$#eqn_array_moji_yose."\n";
	return $out;
}
#	●行列の後ろに（ラベル,[中左左）が書かれているとき、\left[ \begin{array}[cll] とする,(end)


# 確実に = → &=&, 行列の,→& 新規作成000502b
# Usage: &set_ampersand;
# input: $_[0]=$eq[$i]: $iEq
# output: return $out=$eq[$i]
# called by &eqn, 
sub	set_ampersand{
	my	($_org, $_tmp, $_new, $i, $f_last, $f_equal, $f_mat);	# $f_equal:= → &=& が処理されると1, $f_mat:行列のとき1

	$_org = $_;	$_ = $_[0];
	$i = s/\&//g;	if($i>1){	return $_[0];}else{	$_ = $_[0];}	# もし&&があればreturnする

	if( !(/\n$/) ){	$_ = $_."\n";}	# 行末に \n 付加
	$f_last = $f_equal = $f_mat = 0;
	$_new = '';
	while(1){	# texファイル1行づつ処理する

		if( !(s/^[^\n]*\n//) ){	$f_last=1;	$_tmp=$_;}
		else{	$_tmp=$_;	$_=$&;}
		chop;
		# s/^$H_nextComp$//;	# 空行を明確に

		#-------- 行列の,→&
		if( /\\begin\{array\}\{/ ){		$f_mat = 1;}
		elsif( /\\end\{array\}/ ){	$f_mat = 0;}
		if( $f_mat==1 ){	$i = s/[ 	]*\,/	\&/g;}

		#-------- = → &=&
		# print $f_equal.$f_mat.$_."000\n";
		if( $f_equal==0 && length($_)>0 && $f_mat==0 && !(/^[ 	]*$H_nextComp/) ){
			$f_equal=1;
			if( !(s/[ 	　]*([\=≡≠∝＝])[ 	　]*/	&$1& /) ){			# &=&, &:& をつける, 処理の順番を変更 981121b 000218b
				if( !(s/[ 	　]*([\>\<＜＞≧≦])[ 	　]*/	&$1& /) ){	# 000218b
					if( !(s/[ 	　]*\:[ 	　]*/	&\:& /) ){
						$f_equal = 0;
					}
				}
			}
			# print $_."444\n";
		}

		if( length($_)>0 ){	$_new=$_new.$_."\n";}	$_=$_tmp;	# 空行は削除

		if( $f_last==1 ){	last;}
	}
	$_=$_new;	while( s/\n$// ){}	$_new=$_;	# 行末の \n 除去

	if( $f_equal==0 ){	$_=$_new;	s/^([ 	]*)($H_LineNum)([ 	]*)/	$2\&\&	/;	$_new=$_;}	# && をつける000509b
	if( $f_equal==0 ){	$_=$_new;	s/^([ 	]*)($H_nextComp)([ 	]*)/$2	\&\&	/;	$_new=$_;}	# && をつける000509b
	# print $_new,length($_new)."3333333\n";
	$_ = $_org;
	return $_new;
}

#	●行列関連：無限ループになるとき、きちんと修正して Warning を出す, 000227a未
#	 1. 行列関連：下の1行の行列のとき無限ループになる→きちんと修正して Warning を出す
#		a =／ x ＼
#	 2. 行列関連：下のとき(／で終らない)無限ループになる→きちんと修正して Warning を出す
#		a =／ x ＼
#		   ＼ y  |
#	 3. 行列関連：下のとき( , の数が違う)、latex warning → dvi ファイルはできるのでとりあえずほっとく
#		a =／x    ＼
#		   ＼y , z／
#	 4. 行列関連： 行列の | の数がおかしい(まちがえて||a||∞と書いたとき)とき Warning を出す
#sub	eqnMatCheckAndModify{
#}

# 980911, 行列を挟む括弧を/*next*/において括弧の数のエラーを探す (begin) ← 不十分だったので全面書き換え000303a
# aaa \\ bbb \begin{array} ccc \end{array} ddd \\ eee のうち、 bbb, ddd のカッコに\left, \right を付ける

sub	eqnMatKakko{
	$_ = $_[0];
	# print "\nBEGIN\n";print $_;print "\nEND\n";
	while(s/\n[ 	　]*\n/\n/g){}	# eqnarray環境で改行のみの行を削除

	while(s/\n$H_nextComp\n/\n/g){}	# eqnarray環境で改行のみの行を削除

	s/\n$H_nextComp$//;				# eqnarray環境で改行のみの行を削除


	if( /\\(begin|end)\{array\}/ ){
		s/\n/\/\*\\n\*\//g;						# \nを/*\n*/と仮置きする

		$_new = '';
		$count_left = 0;							# \\ ... \\ までの左カッコの数

		$count_right = 0;							# \\ ... \\ までの左カッコの数

		if( s/\/\*\\n\*\/[ 	]*$H_nextComp[ 	]*\\label\{[^\n]*$// ){	$tmp_eqnMatKakko=$&;}else{	$tmp_eqnMatKakko='';}	#000327a \label{}の中にカッコがあるとそれに\leftをつけてしまうので、つけないようにする

		while( s/\/\*\\n\*\/[ 	]*$H_nextComp[ 	]*\\left[\[\(\{][ 	]*\\begin\{array\}.*// ){
			# aaa \\ bbb \begin{array} ccc \end{array} ddd \\ eee のうち、 bbb のカッコに\left, \right を付ける

			# $_ = aaa \\ bbb 
			$_tmp = $&;
			if( s/.*\\\\// ){	$_new = $_new.$&;}
			# $_ = bbb
			&eqnMatKakkoRepl;							# 左カッコ ( [ ｛ に \left を付けて /*1*/ とおく、右カッコ ) ] ｝ に \right を付けて /*1*/ とおく
			$_new = $_new.$_;
			# $_new = aaa \\ bbb 
			$_ = $_tmp;
			# $_ = \begin{array} ccc \end{array} ddd \\ eee
			if( s/(\\end\{array\} \\right[\]\)\}\.])(.*)//){ 
				# aaa \\ bbb \begin{array} ccc \end{array} ddd \\ eee のうち、 eee のカッコに\left, \right を付ける

				$_tmp1 = $1;	$_tmp2 = $2;
				$_org = $_;	&eqnMatNumRawCheck;	$_ = $_org;	# intput:$_, output:$_
				$_new = $_new.$_.$_tmp1;	$_ = $_tmp2;
				# $_ = ddd \\ eee
				$_tmp = '';
				if( s/\\\\.*// ){	$_tmp = $&;	$f_end_of_gyou = 1;}
				else{							$f_end_of_gyou = 0;}
				if( s/\/\*\\n\*\/[ 	]*$H_nextComp[ 	]*\\left[\[\(\{][ 	]*\\begin\{array\}.*// ){
					$_tmp = $&.$_tmp;	$f_end_of_gyou = 0;
				}
				# $_ = ddd
				&eqnMatKakkoRepl;							# 左カッコ ( [ ｛ に \left を付けて /*1*/ とおく、右カッコ ) ] ｝ に \right を付けて /*1*/ とおく
				$_new = $_new.$_;	$_ = $_tmp;
				if( $f_end_of_gyou == 1 ){	eqnMatKakkoErrCheck;}	# エラー処理 ... エラー表示だけで、latex warning の発生を抑える修正は未(不要?)。
			}else{
				&print_warning('XXXXXXXXX error: \begin{array} without \end{array}'."\n");
				&insrt_matoato_warning($LineNum,'\begin{array} without \end{array}');
				last;
			}
		} # end of while
		$_ = $_.$tmp_eqnMatKakko;	#000327a
		eqnMatKakkoErrCheck;	# エラー処理 ... エラー表示だけで、latex warning の発生を抑える修正は未(不要?)。
		$_ = $_new.$_;
		s/\/\*\\n\*\//\n/g;						# \nを/*\n*/と仮置きしたのを戻す
	}
	return $_;
}

sub	eqnMatKakkoRepl{	#000527d修正, 000530f
	while( s/(\\left[ 	]*[\(\[｛])/\/\*$nIgnor\*\// ){		# 左カッコ ( [ ｛ を /*1*/ とおく
		$tmp = $1;	$count_left++;
		$tmp=~s/｛/\\\{/;
		$ptnIgnor[$nIgnor] = $tmp;	$nIgnor++;
	}
	while( s/(\\right[ 	]*[\)\]｝])/\/\*$nIgnor\*\// ){		# 右カッコ ) ] ｝ を /*1*/ とおく
		$tmp = $1;	$count_right++;
		$tmp=~s/｝/\\\}/;
		$ptnIgnor[$nIgnor] = $tmp;	$nIgnor++;
	}
	while( s/([\(\[｛])/\/\*$nIgnor\*\// ){		# 左カッコ ( [ ｛ に \left を付けて /*1*/ とおく
		$tmp = $1;	$count_left++;
		$tmp=~s/｛/\\\{/;
		$ptnIgnor[$nIgnor] = '\left'.$tmp;	$nIgnor++;
	}
	while( s/([\)\]｝])/\/\*$nIgnor\*\// ){		# 右カッコ ) ] ｝ に \right を付けて /*1*/ とおく
		$tmp = $1;	$count_right++;
		$tmp=~s/｝/\\\}/;
		$ptnIgnor[$nIgnor] = '\right'.$tmp;	$nIgnor++;
	}
}

# エラー処理 ... エラー表示だけで、latex warning の発生を抑える修正は未(不要?)。 begin
sub	eqnMatKakkoErrCheck{
	if( $count_left > $count_right ){
		&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): 行列を挟む左カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right."\n");
		&insrt_matoato_warning($LineNum,'行列を挟む左カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right);
		$tmp = ' \\left.' x ($count_right-$count_left);
	}elsif( $count_left < $count_right ){
		&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): 行列を挟む右カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right."\n");
		&insrt_matoato_warning($LineNum,'行列を挟む右カッコが多いかも？( or [ ='.$count_left.', ) or ] ='.$count_right);
	}
	$count_left = 0;							# \\ ... \\ までの左カッコの数

	$count_right = 0;							# \\ ... \\ までの左カッコの数

}
# エラー処理 ... エラー表示だけで、latex warning の発生を抑える修正は未(不要?)。 end

# 980911, 行列を挟む括弧を/*next*/において括弧の数のエラーを探す (end)

#	 3. 行列関連：下のとき( , の数が違う)、latex warning → dvi ファイルはできるし、latex でwarning吐いてミスがわかるが、latex の行番号では元の行が分からないのでチェックは要る(eqnMatKakkoに) 000309a (begin)
#		a =／x    ＼
#		   ＼y , z／
sub	eqnMatNumRawCheck{	# intput:$_, output:$_
	# s/\/\*\\n\*\/[ 	]*$H_nextComp[ 	]*\\left[\[\(\{][ 	]*\\begin\{array\}\{[cl]+\}//;
	s/\\\\(.*)//;
	$j = tr/\,//;	$j = $j + tr/\&//;	# 列数

	$_ = $1;
	while( s/\\\\(.*)// ){
		$_tmp = $1;
		if( $j != (tr/\,//+tr/\&//) ){	# 列数が等しくないとき
			&print_warning('% txt2tex Warning('.$LineNum.'): 行列の列数が、行ごとにばらばらです。'."\n");
			&insrt_matoato_warning($LineNum,'行列の列数が、行ごとにばらばらです。');
			last;
		}
		$_ = $_tmp;
	}
	if( $j != (tr/\,//+tr/\&//) ){	# 列数が等しくないとき
		s/\/\*\\n\*\///;&getLineNum;
		&print_warning('% txt2tex Warning('.$LineNum.'): 行列の列数が、行ごとにばらばらです。'."\n");
		&insrt_matoato_warning($LineNum,'行列の列数が、行ごとにばらばらです。');
	}
}
#	 3. 行列関連：下のとき( , の数が違う)、latex warning → dvi ファイルはできるし、latex でwarning吐いてミスがわかるが、latex の行番号では元の行が分からないのでチェックは要る(eqnMatKakkoに) 000309a (end)
#		a =／x    ＼
#		   ＼y , z／

# 行列の行番号を入れる(begin), 981001
sub	putMatLineNum{
	chop;
	$nlinesub = '';				# 行番号の取得
	if( s/[ 	　]*([0-9][0-9]*Ｃ)[ 	　]*([／\|＼])/$2/ ){
		$nlinesub = $1;
	}else{
		s/[ 	　]*([0-9][0-9]*Ｃ)/$1/;
		$nlinesub = $1;
	}
	$new_ = '';	$fsub = 1;
	$iii6=0;#1002
	while(length($_)>0){				# 行列の中身の行の先頭に行番号を書く,000528a
		$iii6++;if($iii6>500){print '('.$nlinesub.')'."エラー007  ".$_."\n";last;}	# 無限ループ回避策#1002
		s/^.//;
		$new_ .= $&;
		if( $& eq  '／' || $& eq '|' || $& eq '＼' ){
			if( $fsub == 1 ){
				# print $fsub."\n";
				s/^([ 	　]*)/$1$nlinesub/;
			}elsif( !(/^[ 	　]*[／\|＼（]/) && !(/^[ 	　]*$/) ){
				s/^([ 	　]*)/$1$nlinesub/;
			}
			$fsub = -$fsub;
		}
	}
	$_ = $new_."\n";
	# print $nlinesub."後　";print;
}
# 行列の行番号を入れる(end)

# 行列の 中身）の中身をeqに代入(改行：がないとき) (begin) 981004
#	&eqn; からサブルーチン化した 981004
sub	getMatNakami{
	for( $i=0;$i<$nEq;$i++){		# 行列の 中身）の中身をeqに代入
		$_ = $eqn[$i];

		$iii1=0;&getLineNum;#1002
		while(length($_)>0){
			# $iii1++;if($iii1>100){print "エラー002\n";last;}	# 無限ループ回避策#1002
			$iii1++;if($iii1>500){print '('.$LineNum.')'."エラー002\n";last;}	# 無限ループ回避策#1002
			if( /^[／\|＼\n]/o ){
				last;
			}else{
				s/^.//;
				$tmp1[$i] .= $&;
			}
		}
		$eqn[$i] = $_;	#981001
		if( $rawEq>$i ){	#981001
			$tmp1[$i] .= "	\\\\\n";
		}
	}
}
# 行列の 中身）の中身をeqに代入(改行：がないとき) (end)

# 行列の 中身）の中身をeqに代入(改行：があるとき) (begin) 981004, 未完成
sub	eqnMatKaigyou{
	s/改行：.*$//;	# 「改行：」が先頭の行列の中にあるか調べる

	if( /[／\|＼]/o ){	# 「改行：」が先頭の行列の中にないとき
		&getMatNakami;
	}else{				# 「改行：」が先頭の行列の中にあるとき
		# &getMatNakami;return;
		$n_getMatNakami = tr/\,//;	# 改行する列数を調べる( , の数を調べる)
		# print $n_getMatNakami;
		# print @eqn;
		@aft_getMatNakami = '';
		$tmp_getMatNakami = 0;;
		for( $i=0;$i<$nEq;$i++){	# 行列の 中身）の中身をeqに代入
			$_ = $eqn[$i];
			# print $_."\n";
			s/\n//;
			if( $i==0 ){				# 「改行：.*」の前後で分けて後半を $aft_getMatNakami に入れる

				s/改行：(.*)$//;			# 「改行：.*」を１つ削除

				$aft_getMatNakami[$i] = $1;
				$tmp1[$i] = $_;
			}else{
				$iii1a=0;&getLineNum;#1002
				$_tmp_getMatNakami = '';
				while(length($_)>0){				# 第２行以降を前後で分けて後半を $aft_getMatNakami に入れる

					$iii1a++;if($iii1a>100){print '('.$LineNum.')'."エラー002a\n";last;}	# 無限ループ回避策#1002
					if( /^[／\|＼]/ ){
						last;
					}
					s/^.//;	$_tmp_getMatNakami .= $&;
					if( $& eq ',' ){
						$tmp_getMatNakami++;
						if( $tmp_getMatNakami == $n_getMatNakami ){	last;}
					}
				}
				$aft_getMatNakami[$i] = $_;
				$tmp1[$i] = $_tmp_getMatNakami;
			}
			if( $rawEq>$i ){
				$tmp1[$i] .= "	\\\\\n";
			}elsif( !(/^[／\|＼]/) ){
				$tmp1[$i] .= "\n";
			}
			# print "\n".$tmp1[$i]."aaaa\n";print $aft_getMatNakami[$i]."bbbb\n";
		}
		print "AAAA";
		print @tmp1;
		print "BBBB";
		print @aft_getMatNakami;
		print "CCCC";

		for( $i=0;$i<$nEq;$i++){		# 後半の行列の 中身）の中身をeqに代入
			$_ = $aft_getMatNakami[$i];

			$iii1=0;&getLineNum;#1002
			while(length($_)>0){
				# $iii1++;if($iii1>100){print "エラー002\n";last;}	# 無限ループ回避策#1002
				$iii1++;
				if($iii1>100){print '('.$LineNum.')'."エラー002\n";last;}	# 無限ループ回避策#1002
				if( /^[／\|＼\n]/o ){
					last;
				}else{
					s/^.//;
					$tmp1[$i] .= $&;
				}
			}
			$eqn[$i] = $_;	#981001
			if( $rawEq>$i ){	#981001
				$tmp1[$i] .= "	\\\\\n";
			}
		}
	}
}
# 行列の 中身）の中身をeqに代入(改行：があるとき) (end)
#------ eqn2tex の処理(end) ---------


# 式番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelEqn{
	print LABEL encode("utf8","	式番号の参照ラベル一覧\n");
	for($i=0;$i<$numEq;$i++){
		print LABEL encode("utf8",$eqLabel[$i]."\n");
	}
}
# 式番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(end)

#------------------------------------
#	式の行（先頭にタブ）をTeXに変換する処理(eqn2tex)(end)
#------------------------------------




#------------------------------------
#	図の行（図：）をTeXに変換する処理(fig2tex)(begin)
# fig2texの仕様
#●書き方
#	図：（filename.eps）			 ... \begin{figure}[t]なし
#		or
#	図：キャプション（filename.eps） ... ラベル=filename
#		or
#	図：キャプション（ラベル,filename.eps,上下ここ頁,1.0倍） ... キャプション省略時\begin{figure}[t]なし
#------------------------------------
#初期設定(fig2tex)
sub	init_fig2tex{
	$nFig = 0;
	$extension = "(eps|png|jpg)"; # 画像の拡張子設定、追加する場合はここに記述すればいけるかも？ 200624
}

#------ fig2tex の処理(begin) ---------
sub figure{
	my	($tmp1, $f_figureless);
	my	($figFile, $position, $size, $_tmp0, $_tmp);	#000505a
	my	($myLineNum);	#000530d

	if( s/^	[	　]*($H_LineNum)図：([ 	　]*)// ){	#990103a
		$LineNum = $1;	$myLineNum=$LineNum;	$myLineNum=~s/Ｃ$//;
		$f_figureless=0;	if( length($2)==0 ){	$f_figureless=1;}	#図：の後空白がないとき000504h
		if( s/^(.*)（[ 	　]*(.*)[ 	　]*）[ 	　]*\n/$2/ ){
			if( !($f_figureless==1 && length($1)==0) ){	#キャプションがあるとき000504h
				$figCaption[$nFig] = $1;	$f_figureless=0;
			}
			# default
			$position='tbh';
			$size='width=\\hsize';	#020322a
			# $size='xsize=\\hsize';
			$figName='noname.eps';

			# $_tmp0=$_;	$tmp1='[ 	]*([上下こ頁 ]+)[ 	]*';	# $positionの設定
			# $_tmp0=$_;	$tmp1='[ 	]*([上下こ頁強制 ]+)[ 	]*';	# $positionの設定 211101
			$_tmp0=$_;	$tmp1='[ 	]*([!上下こ頁強制 ]+)[ 	]*';	# $positionの設定 220101

			if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){
				# $_tmp=$_;	$_=$1;	y/上下頁/tbp/;	s/ここ/h/;
				# $_tmp=$_;	$_=$1;	y/上下頁/tbp/;	s/ここ/ht/; # 200624
				$_tmp=$_;	$_=$1;	y/上下頁/tbp/;	s/ここ/ht/;	s/強制/H/; # 211101
				if( length($_tmp)==0 || /こ/ ){	$_=$_tmp0;}	# （）の中身がなくなったらfilenameとみなす
				else{							$position=$_;	$_=$_tmp;}
			}
			$_tmp0=$_;	$tmp1='[ 	]*([0-9\.]+)[ 	]*倍[ 	]*';	# $sizeの設定

			if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){
				$_tmp=$_;	$_=$1;
				if( length($_tmp)==0 ){	$_=$_tmp0;}	# （）の中身がなくなったらfilenameとみなす
				else{				$size='width='.$_.'\\hsize';	$_=$_tmp;}#020322
				# else{				$size='xsize='.$_.'\\hsize';	$_=$_tmp;}
			}
			# $figFileの設定（拡張子.epsを持つことを前提、もしラベルがなければ（$_に,が含まれなければ）、拡張子にかかわらずファイル名とみなす。
			if( !(/\,/) ){
				# s/^[ 	]*//;	s/[ 	]*$//;	$figFile=$_;	s/\.eps$//;	$figLabel[$nFig] = &repl_label_moji($_);
				# s/^[ 	]*//;	s/[ 	]*$//;	$figFile=$_;	s/\.(eps|png|jpg)$//;	$figLabel[$nFig] = &repl_label_moji($_); # 200624
				s/^[ 	]*//;	s/[ 	]*$//;	$figFile=$_;	s/\.${extension}$//;	$figLabel[$nFig] = &repl_label_moji($_); # 200624
			}else{
				# $_tmp0=$_;	$tmp1='[ 	]*([^ 	]+\.eps)[ 	]*';
				# $_tmp0=$_;	$tmp1='[ 	]*([^ 	]+\.(eps|png|jpg))[ 	]*'; # 200624
				$_tmp0=$_;	$tmp1='[ 	]*([^ 	]+\.' . $extension . ')[ 	]*'; # 200624
				if( s/\,$tmp1\,/\,/ || s/^$tmp1\,// || s/\,$tmp1$// ){	# .epsがある
					$_tmp=$_;	$_=$1;
					$figFile = $_;	$_=$_tmp;
				}else{	# （ラベル,filename）と後ろをファイル名とみなす
					s/\,[ 	]*([^ 	]+)[ 	]*$//;	$figFile = $1;
				}
				s/^[ 	]*//;	s/[ 	]*$//;	$figLabel[$nFig] = &repl_label_moji($_);
			}
			if( /\,/ ){
				$_tmp=$_;	$_=$_tmp0;
				# 000530d &getLineNum;
				&print_warning('% txt2tex Warning('.$myLineNum.'):図の参照ラベル名（'.$_tmp.'）に,が含まれます'."\n");
				&insrt_matoato_warning($LineNum,'図の参照ラベル名（'.$_tmp.'）に,が含まれます。');
			}
			# print $figCaption[$nFig]." - ".$figLabel[$nFig]." - ".$figFile." - ".$position." - ".$size."\n";
		}else{	# （...）がないとき
			chop;	s/[ 	]*$//;
			$figCaption[$nFig] = $_;
			$figFile = $figLabel[$nFig] = "noname.eps";
			$_ = $tmp1;
			# 000530d &getLineNum;
			&print_warning("% txt2tex Error\(".$myLineNum."\)\:図のepsファイル名が明記されてません。\n");
			&insrt_matoato_warning($LineNum,'図のファイル名が明記されてません。');
		}

		if( $f_figureless==0 ){
			$H_OUT=$H_next.'\begin{figure}['.$position.']'."\n";	&print_OUT_euc;
			$H_OUT=$H_next.'	\centering'."\n";	&print_OUT_euc;
		}else{ # 220101
			$H_OUT=$H_next.'\begin{center}'."\n";	&print_OUT_euc;
		}

		$H_OUT=$H_next.'	\includegraphics['.$size.']{'.$figFile.'}';	&print_OUT_euc;		#scale to full width and keep aspect ratio 020322a
		# $H_OUT=$H_next.'	\psbox['.$size.']{'.$figFile.'}';	&print_OUT_euc;		#scale to full width and keep aspect ratio
		# $H_OUT=$H_next.'	\psbox[xsize=0pt]{'.$figFile.'}';	&print_OUT_euc;		#use the natural sizes (default)
		# $H_OUT=$H_next.'	\epsfile{file='.$figFile.',width=60mm}';	&print_OUT_euc;
		if( $f_figureless==0 ){
			$H_OUT=" \\\\\n";
			$H_OUT=$H_OUT.$LineNum.'"	\caption{"'.$figCaption[$nFig].'"}"'."\n";
			$H_OUT=$H_OUT.$H_next.'	\label{'.$figLabel[$nFig].'}'."\n";	# fig:を付けない, 981101
			$H_OUT=$H_OUT.$H_next.'\end{figure}'."\n";	&print_OUT_euc;

			$nFig++;
		}else{
			$H_OUT='	\label{'.$figLabel[$nFig].'}'."\n";	&print_OUT_euc;# fig:を付けない, 981101
			$H_OUT=$H_next.'\end{center}'."\n";	&print_OUT_euc; # 220101
			# $nFig++;#110828b# labelを図番号「図（fig1）」に反映させない（図のキャプションも番号も表示されないので）
		}

		next;
	}
}
#------ fig2tex の処理(end) ---------

#------------------------------------
#	複数の図の行（[縦横]：）をTeXに変換する処理(subfig2tex)(begin)
# subfig2texの仕様
#●書き方
#	[縦横]：Caption（Label,position：Caption1（filename1.eps,Label1,size倍）,Caption2（filename2.png,Label2,size倍）, ... ）	基本形。「filename,Label,size」、「Label,position」は順不同。拡張子は省略不可。
#		or
#	[縦横]：Caption（position：Caption1（filename1.eps,size倍）,Caption2（filename2.png,size倍）, ... ）						ラベル省略系。ラベルは図全体：「Caption」,図単体：「filename」になる。
#		or
#	[縦横]：Caption（：Caption1（filename1.eps）,Caption2（filename2.png）, ... ）												めんどくさい人向け。ラベルは上記。位置は「htbp」、大きさは「1.0倍」と見なす。
#		or
#	[縦横]：（：（filename1.eps）,（filename2.png）, ... ）																		さらにめんどくさい人向け。位置と大きさは上記。キャプションは半角スペース。ラベルは図全体：「noname$nFig」,図単体：「filename」になる。
#------------------------------------
#初期設定(subfig2tex)
sub init_subfig{ # 200624
	$nsubFig = 0; # forループに使うカウント
	$nsubFig1 = 0; # subfigのカウント
	$nsubFig2 = 0; # label用のカウント
	$loop = 0; # 複用カウント
}

#------ subfig2tex の処理(begin) ---------
sub subfig{ # 200624
	my ($f_figureless,$position,$size0,$size,$figName);

	if(s/^	[ 	　]*($H_LineNum)(縦|横|複+)：([ 	　]*)//){ # 複数図検出
		$f_figureless = 0;
		if(length($3)==0){
			$f_figureless = 1;
		}
		$LineNum = $1; # 現在の行数
		$figMode = $2; # 縦か横か
		$figMode_sub = 1; # subfigにするか
		if(length($figMode)!=1){
			$figMode = '複';
			$figMode_sub = 0;
		}

		# figure本体の処理(begin)
		# if(s/^(.*)（[ 	　]*(.*)：(.*)[ 	　]*）[ 	　]*\n/$2$3/){
		# if(s/^(.*)（[ 	　]*(.*)：(.*)[ 	　]*）[ 	　]*\n/$2$3/){ # 複図配置設定の追加
		if(s/^(.*)（[ 	　]*(.*)：(.*)[ 	　]*）[ 	　]*\n/$3/){ # 複設定用210701
			if(!($f_figureless==1 && length($1)==0)){
				$figCaption[$nFig] = $1; # figure本体のキャプション
				$f_figureless = 0;
			}else{ # figureのキャプションが存在しない時
				$figCaption[$nFig] = " ";
			}

			$position = "htbp";
			$size0 = "scale=";
			# $size0 = "width=";
			# $size1 = "\\hsize";
			$figName = "noname";
			$num_sub_position = '';

			# $_temp0 = $_; # $_temp0=$2$3->fig本体の情報を取得するまで変更しない
			$_tmp0 = $2; # figure本体の情報
			# $_tmp1 = $3; # subfigureの情報
			if(/^(.*)）[ 	　]*（([^）]*)[ 	　]*$/){
				$_tmp1 = $1;
				$num_sub_position = $2;
				$_ = $_tmp1;
				@subFig = split(/）[ 	　\,]*/);
				$_ = $num_sub_position;
				$numtemp = 0;
				while(s/[ 	　\,]*(\d)[ 	　\,]*(.*)/$2/){
					$numtemp += $1;
				}
				if($numtemp + $_ != $#subFig + 1){
					$num_sub_position = '';
					&insrt_matoato_warning($LineNum,'図の個数と指定した並びが異なります。自動調整しました。');
				}
			}else{
				if($figMode eq '複'){
					&insrt_matoato_warning($LineNum,'図の配置が指定されていません。自動調整しました。');
				}
				$_tmp1 = $_;
			}
			if(length($num_sub_position) == 0){
				$_ = $_tmp1;
				@subFig = split(/）[ 	　\,]*/);
				$nsubFig = $#subFig;
				if($figMode eq '縦'){
					for($temp0701=0;$temp0701<=$#subFig;$temp0701++){
						$num_sub_position .= '1,';
					}
					chop($num_sub_position);
				}elsif($figMode eq '横'){
					$num_sub_position = $#subFig + 1;
				}else{
					while($nsubFig > 0){
						$num_sub_position .= '2,';
						$nsubFig -= 2;
					}
					if($nsubFig == 0){
						chop($num_sub_position);
						chop($num_sub_position);
						$num_sub_position .= '3';
					}else{
						chop($num_sub_position);
					}
				}
			}
			$_ = $_tmp1;
			# $tmp1 = "[ 	　]*([上下こ頁]+)[ 	　]*";
			# $tmp1 = "[ 	　]*([上下こ頁強制]+)[ 	　]*"; # 211101
			$tmp1 = "[ 	　]*([!上下こ頁強制]+)[ 	　]*"; # 220101
			$_ = $_tmp0;

			if( s/\,$tmp1$// || s/^$tmp1\,// || s/^$tmp1$//){ # 位置情報がある場合
				$_tmp = $_;
				$_ = $1;
				y/上下頁/tbp/;
				s/ここ/ht/;
				s/強制/H/; # 211101
				if(length($_tmp)==0){
					$_ = $_tmp0; # 位置情報を抜きとった後何も残らなかった場合、位置情報をラベルとみなす
				}else{
					$position = $_;
					$_ = $_tmp;
				}
			}

			if(!(/\,/)){
				s/^[ 	　]*//;
				s/[ 	　]*$//;
				if($figMode_sub){
					if((length($_) != 0) && ($figCaption[$nFig] ne " ")){ # ラベルもキャプションもある場合
						$figLabel[$nFig]=&repl_label_moji($_);
					}elsif((length($_) == 0) && ($figCaption[$nFig] ne " ")){ # ラベルはないがキャプションはあるとき => キャプションをラベルに
						$tmp_caption = $figCaption[$nFig];
						$figLabel[$nFig]=&repl_label_moji($tmp_caption);
					}elsif((length($_) != 0) && ($figCaption[$nFig] eq " ")){ # ラベルがあるのにキャプションがないとき
						$figLabel[$nFig]=&repl_label_moji($_);
						&print_warning("% txt2tex Error\(".$LineNum."\)\:図にキャプションがないのにラベルがあります。つけることをオススメするよ\(\*∂v∂\)\n");
						&insrt_matoato_warning($LineNum,'図にキャプションがないのにラベルがあります。つけることをオススメするよ(*∂v∂)');
					}else{ # ラベルもキャプションもない場合
						$tmp_caption = $figName . $nFig;
						$figLabel[$nFig]=&repl_label_moji($tmp_caption);
						&print_warning("% txt2tex Error\(".$LineNum."\)\:図にラベルもキャプションもありません。つけることをオススメするよ\(\*∂v∂\)\n");
						&insrt_matoato_warning($LineNum,'図にラベルもキャプションもありません。つけることをオススメするよ(*∂v∂)');
					}
				}
			}else{
				&print_warning("% txt2tex Error\(".$LineNum."\)\:図の引数が多いです。次の処理に移ります\n");
				&insrt_matoato_warning($LineNum,'図の引数が多いです。次の処理に移ります。');
				next;
			}
			$subFigLabel1->[$nsubFig2][0] = $figLabel[$nFig];
			# figure本体の処理(end)

			# subfigureの処理(begin)
			$_ = $_tmp1;

			$H_OUT = $H_next.'\begin{figure}['.$position."]\n";	&print_OUT_euc;

			@subFig = split(/）[ 	　\,]*/); # $subFig[n]=[ 	　]*SubCaption[ 	　]*（...
			$tmp000 = round((1/($#subFig + 1)/$documentpoint) , 2); # 1/subfigの数でminipageの大きさを決定する(横のみ)
			$_ = $num_sub_position;
			$loop = 0;
			while(s/[ 	　\,]*(\d)[ 	　\,]*(.*)/$2/){
				$temp_num = $_;
				$max_num = $1;
				$tmp000 = round((1/$max_num/$documentpoint) , 2);
				for($nsubFig=0;$nsubFig<$max_num;$nsubFig++){
					$H_OUT = $H_next.'	\begin{minipage}[t]{'.$tmp000.'\hsize}'."\n".$H_next."		\\centering\n";
					&print_OUT_euc;
					$_ = $subFig[$nsubFig + $loop];
					$myLineNum = $nsubFig.$LineNum;
					if(s/^[ 	　]*(.*)（[ 	　]*(.*)[ 	　]*/$2/){
						if((length($1)!=0) && ($1 !~ /^\ $/)){ # subfigのキャプションがある場合 201226追記 文字が何もない場合「\ 」がマッチするらしい 210529追記 文字が何もない場合のみマッチするように変更 -> 多分「 」、「　」や「\t」はその文字がsubcaptionになると思われる
							$subFigCaption[$nsubFig]=$1;
							$subCaptionexist = 1;
						}else{ # ない場合
							# $subFigCaption[$nsubFig]="";
							$subCaptionexist = 0;
						}

						$_tmp = $_;
						$tmp1 = "[ 	　]*([0-9\.]+)[ 	　]*倍[ 	　]*";
						if(s/^$tmp1\,// || s/\,$tmp1\,/\,/ || s/\,$tmp1$//){ # 倍率が指定されている場合
							$_tmp = $_;
							$scale[$nsubFig] = $size0.$1;
							# $scale[$nsubFig] = $size0.$1.$size1;
						}else{ # されていない場合
							$scale[$nsubFig] = $size0."1.0";
							# $scale[$nsubFig] = $size0."1.0".$size1;
						}

						$_ = $_tmp;
						$tmp1 = "[ 	　]*([^ 	　]+.*)[ 	　]*\.[ 	　]*" . $extension . "[ 	　]*"; # $1=filename,$2=拡張子
						if(s/^$tmp1\,// || s/\,$tmp1\,/\,/ || s/\,$tmp1$//){ # labelがファイル名より後に記述されている場合
							$subFigFileName = $1;
							$subFigFile = $1."\.".$2;
						}elsif(s/$tmp1//){ # labelがファイル名より先に記述されてる場合、もしくはlabelが存在しない場合
							$subFigFileName = $1;
							$subFigFile = $1."\.".$2;
						}else{ # Fileが存在しない場合
							$subFigFileName = "Noname";
							$subFigFile = "Noname.png";
							$_ = "";
							&insrt_matoato_warning($myLineNum,'ファイル名に拡張子は入ってますか？');
						}

						s/^[ 	　]*//;
						s/[ 	　]*$//;
						if(length($_) == 0){ # labelが存在しない場合
							$subFigLabel[$nsubFig1] = &repl_label_moji($subFigFileName);
						}else{
							$subFigLabel[$nsubFig1] = &repl_label_moji($_);
						}
					}
					$H_OUT = $H_next."		\\includegraphics[keepaspectratio,".$scale[$nsubFig]."]{".$subFigFile."}\n"; &print_OUT_euc;
					if($subCaptionexist == 1){
						if($figMode_sub){
							$H_OUT = $myLineNum.'"		\subcaption{"'.$subFigCaption[$nsubFig].'"}"'."\n";
						}else{
							$H_OUT = $myLineNum.'"		\caption{"'.$subFigCaption[$nsubFig].'"}"'."\n";
						} 
						&print_OUT_euc;
					} # subcaptionいらない場合の作成 201226
					if($subCaptionexist == 1){$H_OUT = $H_next."		\\label{".$subFigLabel[$nsubFig1]."}\n"; &print_OUT_euc;} # subcaptionがない時labelは意味をなさないため削除 201226
					if(($nsubFig + 1 == $max_num) && ($temp_num =~ /^[ 	　\,]*(\d)[ 	　\,]*(.*)/)){
						$H_OUT = $H_next."	\\end{minipage}\\\\\n";  &print_OUT_euc;
					}else{
						$H_OUT = $H_next."	\\end{minipage}\n";  &print_OUT_euc;
					}
					if($figMode_sub){
						$subFigLabel1->[$nsubFig2][$nsubFig + $loop + 1] = $subFigLabel[$nsubFig1];
					}else{
						$figLabel[$nFig]=$subFigLabel[$nsubFig1];
						$nFig++;
					}
					$nsubFig1++;
				}
				$loop += $max_num;
				$_ = $temp_num;
			}

			if($figMode_sub){
				$H_OUT = $LineNum.'"	\caption{"'.$figCaption[$nFig].'"}"'."\n"; &print_OUT_euc;
				$H_OUT = $H_next."	\\label{".$figLabel[$nFig]."}\n"; &print_OUT_euc;
			}
			$H_OUT = $H_next."\\end{figure}\n"; &print_OUT_euc;

			if($figMode_sub){$nFig++;}
			$nsubFig2++;
		}
		next;
	}
	1;
}
#------ subfig2tex の処理(end) ---------


#------ 四捨五入する処理(begin) ---------
sub round{ # 200624 &round($num,$dig)で$numを小数点以下$dig桁に丸める
	my $val = shift;
	my $col = shift;
	my $r = 10 ** $col;
	my $a = ($val > 0) ? 0.5 : -0.5;
	return int($val * $r + $a) / $r;
}
#------ 四捨五入する処理(end) ---------



#	●debug: #"define"文 → \#define文 に変換する，\label{#define文} → LaTeXエラーになるので\label{＃define文} に変換する, 000430a
#		本文では、# → \#
#		ラベルは、# → ＃ と変換する。
# Usage: $label = &repl_label_moji($ptn);
# input: $_ (ラベルに使う文字列)
# output: return $_ (ラベルに使う修正後の文字列)
# called by &fig2tex, 
sub	repl_label_moji{
	my	($_org, $label, $aft);

	$_org = $_;	$_ = $_[0];
	s/\\([\#])/$1/g;	#000612c
	y/\#\%\~\\\{\}/＃％￣＼｛｝/;

	$aft = '';
	while( s/\/\*([0-9]+)\*\/(.*)$// ){	# /*10*/ を戻す000718d
		$aft = $aft.$_.$ptnIgnor[$1];	$_ = $2;
	}
	$_ = $aft.$_;

	$label = $_;	$_ = $_org;
	return $label;
}


# 図番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelFig{
	print LABEL encode("utf8","	図番号の参照ラベル一覧\n");
	for($i=0;$i<$nFig;$i++){
		print LABEL encode("utf8",$figLabel[$i]."\n");
	}
}
# 図番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(end)

# 複図番号の参照ラベルのファイルへの出力（参照処理には使わないが、重複チェックに使う）(begin)
sub writeLabelsubFig{
	print LABEL encode("utf8","	複図番号の参照ラベル一覧\n");
	for($i=0;$i<$nsubFig1;$i++){
		print LABEL encode("utf8",$subFigLabel[$i]."\n");
	}
}
# 複図番号の参照ラベルのファイルへの出力（参照処理には使わないが、重複チェックに使う）(end)

#------------------------------------
#	図の行（図：）をTeXに変換する処理(fig2tex)(end)
#------------------------------------



#------------------------------------
#	式の行を読み飛ばす処理(begin)
#------------------------------------
sub nextIFtab{
	if( /^	/ ){
		$H_OUT=$_;	&print_OUT_euc;	#980906
		next;
	}
}
#------------------------------------
#	図表式の行を読み飛ばす処理(end)
#------------------------------------





#------------------------------------
#	段落の空行を改行にする処理(begin)
#------------------------------------
sub getKaigyou{
	# if( s/^　//o ){
	if( s/^　//o || s/^  ([^ 	　])/$1/o || s/^  $//o ){	#000504d, 000510b
		$H_OUT=$H_next."\n";	&print_OUT_euc;
	}
}
#------------------------------------
#	段落の空行を改行にする処理(end)
#------------------------------------





#------ 文章の中の式の両サイドに$を挿入にする処理(begin) ---------
sub dollar2{	# 000210f 新規作成
	my	($i, $tmp, $tmp1, $tmp2, $tmp3, $_dollar2, $_dollar2b);

	if( s/^([ 	　]*)([0-9][0-9]*Ｃ)// ){	$_dollar2 = $&;}
	else{									$_dollar2 = '';}
	chop;
	while( s/(\/\*[0-9]+\*\/)(.*)$// ){	# /*10*/を$...$の中に入れない
		$_dollar2a = $1;	$_dollar2b = $2;
		&dollar;
		$_dollar2 = $_dollar2.$_.$_dollar2a;	$_ = $_dollar2b;
	}
	&dollar;
	$_ = $_dollar2.$_;

	s/\$\\ \$/\\ /g;	# 000213j 
	s/(.*)\$\.\$(.*)/$1\.$2/;	# ピリオドのみは$に入れない => ピリオドのみが改行されてしまう	201001

	# $A $and$ B$ → $A$ and $B$ にする

	$i = 0;	$_dollar2 = '';
	while( s/( *)\$( *)(.*)$// ){
		$tmp1=$1;	$tmp2=$2;	$tmp3=$3;
		if( $i==0 ){	# 初めの $
			$_dollar2 .= $_.$tmp1.$tmp2.'$';	$_ = $tmp3;	$i = 1;
		}else{			# 終りの $
			if( !(/\\$/ && $tmp1=~/ /) ){	$_dollar2 .= $_.'$'.$tmp1.$tmp2;	$_ = $tmp3;	$i = 0;}
			else{							$_dollar2 .= $_.$tmp1.'$'.$tmp2;	$_ = $tmp3;	$i = 0;}	#000520f
		}
		# if( $i == 1 ){	print 'Warning:$が奇数';
	}
	
	$_ = $_dollar2.$_."\n";
}

sub dollar{
	# 980917	if( /^[a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=]/ ){	# 先頭に$が必要か判断
	# 981101	if( /^[\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=]/ ){	# 先頭に$が必要か判断
	if( /^[\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\<\>]/ ){	# 先頭に$が必要か判断, <>追加 981101
		$flag[0] = $flag[1]= 1;
		$tmp = "\$";
	}else{
		$flag[0] =	$flag[1]= 0;
		$tmp = "";
	}
	# 000210f	chop;
	$i=0;#	$flag[1]=0;
	while(length($_)>0){	# while($_)では 0 を''とみなすようだ000514a
		s/^.//;
		$tmp .= $&;
		# 980917		if( /^[a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\,]/ ){
		# 980920		if( /^[\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\,]/ ){
		# 981101		if( /^[\.\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\,]/ ){
		if( /^[\.\|a-zA-Z0-9\\\_\^\+\-\*\/\(\)\[\]\{\} \=\,\<\>]/ ){	# 先頭に$が必要か判断, <>追加 981101
			$flag[0] = 1;
		}else{
			$flag[0] = 0;
		}
		if( $flag[0]==1 && $flag[1]==0 ){
			$tmp .= "\$";
		}
		if( $flag[0]==0 && $flag[1]==1 ){
			$tmp .= "\$";
		}
		$flag[1] = $flag[0];
		$i++;
	}
	$_ = $tmp;
	# 000210f	$_ = $tmp."\n";

	#	# 行番号を元に戻すLineNum, 980925(begin), 000210f comment
	#	s/^([ 	　]*)\$([0-9][0-9]*)\$(Ｃ)/$1$2$3/;
	#	s/^\$([ ]*)([0-9][0-9]*)\$(Ｃ)/$1$2$3/;
	#不要	s/(	\&\& )\$([0-9][0-9]*)\$(Ｃ)/$1$2$3/;
	#	# 行番号を元に戻すLineNum, 980925(begin)

	#	●表：で$a  \\$はjlatex error(問題なくdviファイルはできるが)なので$a$	\\に修正, 000212d, dollarに移動000504g
	s/\$([ 	]*\\\\)\$/$1/o;
	s/([ 	]*\\\\)\$/\$$1/o;
}
#------ 文章の中の式の両サイドに$を挿入にする処理(end) ---------




#------ $, $を, にする処理 (begin)---------
sub dollar_ignor{
	#	s/\$\/\*/\/\*/g;
	#	s/\*\/\$/\*\//g;
	#980920 debug
	#	$/*8*/$	→	/*8*/
	#	/*8*/$	→	$/*8*/
	#	$/*8*/	→	/*8*/$
	#000210f comment begin
	#	s/\$(\/\*[0-9][0-9]*\*\/)\$/$1/g;
	#	s/(\/\*[0-9][0-9]*\*\/)\$/\$ $1/g;	# ' ' が必要（下の変換で戻さない）
	#	s/\$(\/\*[0-9][0-9]*\*\/)/$1\$/g;
	#	s/\$ (\/\*[0-9][0-9]*\*\/)/\$$1/g;	# 上２行を元に戻す（' 'を除く）
	#	s/\$(\/\*[0-9][0-9]*\*\/)\$/$1/g;	#980923 /*1*//*2*//*3*/のときのエラー回避

	#000210f comment end
	#	$/*8*/ /*8*/$	→	/*8*/ /*8*/
	#	s/\$(\/\*[0-9][0-9]*\*\/[ 	　]*\/\*[0-9][0-9]*\*\/)\$/$1/g;

		# 空白$  $の$をとる, 980911
		#	●debug: Ё, ё → $\$"${E}$, $\$"${e}$ →  \"{E}, \"{e}, $"$を"に変換する, 000501a,000625h
	s/\$([ 	,\"”]*)\$/$1/g;	# 000210f"


	# Fig.とfig.とFigureとfigureの下付き処理と$の処理をしない981119c
	s/\$(Fig|fig|Figure|figure|Table|table)([\. 0-9]*)\$/$1$2/g;

	&check_kakko_in_dollar;	#括弧の対応が１行単位なので$...$の中で括弧の対応をとる, 981119b

	&rm_dollar_in_frac;	# \frac{...}{...}の{}の中の$を削除する 000718b

	&rm_dollar_only_suuji;	#◯txt2tex:debug: 10 -> $10$をやめる（数字のみはdollarしない）,000801d
}
#------ $, $を, にする処理 (end)---------

#	◯txt2tex:debug: 10 -> $10$をやめる（数字のみはdollarしない）,000801d
sub	rm_dollar_only_suuji{
	my	($tmp, $_aft, $f);
	chop;
	$_aft='';	$f=0;
	while( s/(.*[^\\])\$// ){
		$tmp=$1;
		if( $f==0 ){	# $...$の中でないとき
			$_aft=$_.$_aft;	$_=$tmp;	$f=1;
		}else{			# $...$の中

			if( /^[0-9\,]+$/ ){	# $10,$のとき
			}elsif( /^[0-9\, 	]*[\[\]\(\)][0-9\, 	]*$/ ){	# 括弧が１つだけのとき000813h
			}else{
				if(/\\[a-zA-Z0-9]+$/){	$_aft=~s/^ //;}	# $\alpha$ AA --> $\alpha$AA,000801f
				$_ = '$'.$_.'$';
			}
			$_aft=$_.$_aft;	$_=$tmp;	$f=0;
		}
	}
	$_=$_.$_aft."\n";
}


#	◯txt2tex:debug: "txt2tex"/"tex2txt" -> ${\frac{$txt2tex$}{$tex2txt$}}$ -> ${\frac{txt2tex}{tex2txt}}$, \frac{...}{...}の{}の中の$を削除する 000718b
sub	rm_dollar_in_frac{
	my	($_new, $nakami, $_aft);
	$_new='';	chop;
	while( s/(\\frac)[ 	]*(\{.*)// ){
		# \frac{num}
		$_new=$_new.$_.$1;	$_=$2;	$nakami = &get_kakko_nakami_LtoR("quiet");	$_aft=$_;
		$nakami=~s/([^\\])\$/$1/g;	$_new=$_new.$nakami;
		# {den}...
		$_=$_aft;	s/^[ 	]*//;	$nakami = &get_kakko_nakami_LtoR("quiet");	$_aft=$_;
		$nakami=~s/([^\\])\$/$1/g;	$_new=$_new.$nakami;

		$_=$_aft;
	}
	$_=$_new.$_."\n";
}

#		●aあああi)縲彿v) → $\left. \left. a$あああ $i\right)\sim {i_{v}}\right)$
#		  括弧の対応が１行単位なので$...$の中で括弧の対応がとれない ex. $\left($...$\right)$
#			→ &check_kakko_in_dollar追加で対応, 981119b
#括弧の対応が１行単位なので$...$の中で括弧の対応をとる, 981119b, begin
#	●txt2tex:debug: )( -> $\right)\left($ ... latex error -> $)($, 000510d
sub	check_kakko_in_dollar{
	my	($tmp1, $tmp2, $_bef, $_aft, $f, $f_warning);
	my	($_tmp00, $n, $str_tmp, $ntmp, $_tmp000, $_1);

	$_tmp00 = '';	$n = 0;
	chop;
	s/\\right([0-9a-zA-Z\_])/\\r-i-g-h-t-$1/g;	s/\\left([0-9a-zA-Z\_])/\\l-e-f-t-$1/g;
	$f_warning=0;	&getLineNum;
	while(s/(.*)\$(.*)/$1/){
		$str_tmp = $2;
		#-----------------------
		$ntmp=$n;	while($ntmp>0){	$ntmp-=2;}
		if( $ntmp==-1 ){
			$_tmp000 = $_;	$_ = $LineNum."Ｃ".$str_tmp;
			# if(/\(|\)/ ){print ":".$_.":\n";}
			&kakko2tex;
			s/^[0-9][0-9]*Ｃ//;
			s/\n$//;
			# 000510d begin, ex: ')())()((a)は()()a()aは(a)a(a)'
			# if(/\(|\)/ ){print "|".$_."|\n";}
			$_bef='';	$_aft=$_;	$f=0;
			# while( s/(\\right|\\left)(.*)$// ){
			$_=$_." ";	#行末に" "を足して "\right$"をみる000530e
			while( s/(\\right|\\left)([^a-zA-Z0-9\_].*)$// ){
				$_1=$1;	$_bef=$_bef.$_;	$_aft=$2;	$_aft=~s/ $//;
				if( $_1 eq "\\left" ){	$f++;}elsif( $_1 eq "\\right" ){	$f--;}
				if( $f>=0 ){
					$_bef=$_bef.$_1;
				}else{
					if( $_aft=~/^\./ ){	$tmp2=$_;	$_=$_aft;	s/^\.//;	$_aft=$_;}
					$tmp2=$_;	$_=$_aft;
					if( $_1 eq "\\right" ){
						if( !(s/^(.*)\\left\./$1/) ){	if( !(s/^(.*)\\left/$1/) ){	$_bef=$_bef."\\right";}}
						# if( !(s/\\left\.(.*)$/$1/) ){	if( !(s/\\left(.*)$/$1/) ){	$_bef=$_bef."\\right";}}
					}else{
						if( !(s/^(.*)\\right\./$1/) ){	if( !(s/^(.*)\\right/$1/) ){	$_bef=$_bef."\\left";}}
						# if( !(s/\\right\.(.*)$/$1/) ){	if( !(s/\\right(.*)$/$1/) ){	$_bef=$_bef."\\left";}}
					}
					$_aft=$_;	$_=$tmp2;	$f_warning=1;
				}
				$_=$_aft;	$_=$_." ";
				# if(/\(|\)/ ){print ":".$_bef." : ".$_aft.":\n";}
			}
			$_=$_bef.$_aft;
			# if(/\(|\)/ ){print ":".$_bef." : ".$_aft.":\n";}
			# 000510d end
			$str_tmp = $_;
			$_ = $_tmp000;
		}
		#-----------------------
		$n++;
		$_tmp00 = '$'.$str_tmp.$_tmp00;
	}
	$_ = $_.$_tmp00."\n";
	s/\\r-i-g-h-t-([0-9a-zA-Z\_])/\\right$1/g;	s/\\l-e-f-t-([0-9a-zA-Z\_])/\\left$1/g;
	if( $f_warning ){
		&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): カッコが")("のように開いています。'."\n");
		&insrt_matoato_warning($LineNum,'カッコが")("のように開いています。');
	}

	#\left( \right.と \left. \right) をそれぞれ ( と ) にする

	while(s/\\left[ 	]*(\(|\[)[ 	]*\\right[ 	]*(\.)/$1/g){}
	while(s/[ 	]*\\left[ 	]*(\.)[ 	]*\\right[ 	]*(\)|\])/$2/g){}	#00813o
	while(s/\\left[ 	]*(\(|\[)[ 	]*\\right[ 	]*(\)|\])/$1$2/g){}

	# 000613a begin
	$_=' '.$_;	$_aft='';
	while( s/(.*[^\\])\$/\$/ ){
		$_aft = $_.$_aft;
		$_ = $1;
		if( s/(.*[^\\])\$/\$/ ){
			$tmp1 = $1;
			while( s/([0-9a-zA-Z])[ 	]+([\[\]\{\}\(\)])/$1$2/ ){}	#000613a
			while( s/([\[\]\{\}\(\)])[ 	]+([0-9a-zA-Z])/$1$2/ ){}		#000613a
			$_aft = $_.$_aft;
			$_ = $tmp1;
		}else{
			print "ERROR txt2tex 000613a $_ \n";
			$_aft = $_.$_aft;
		}
	}
	$_ = $_.$_aft;	s/^.//;
	# 000613a end
}



sub	debug981215b{
	chop;
	# ●"\t表目次：" を式にしてしまう。 → タブを削除, 981215b
	s/^[ 	　]*($H_LineNum)([表図]*)(目次：)[ 	　]*$/$1$2$3/;
	# ●1-3節：、定理２：なども1-3、２などを無視して変換できるようにする, 990102a
	s/^[0-9０-９\.．\-ー─]*(章|節+)：/$1：/;						# 990102a
	s/^[0-9０-９\.．\-ー─]*(章|節+)(\*|\$\\ast\$|＊)：/$1$2：/;						# 210701
	s/^($H_LineNum)[0-9０-９\.．\-ー─]*(章|節+|付録)：/$1$2：/;	# 990102a
	s/^($H_LineNum)[0-9０-９\.．\-ー─]*(章|節+|付録)(\*|\$\\ast\$|＊)：/$1$2$3：/;	# 210701
	s/^($H_LineNum)(定理|補題|証明)[0-9０-９\.．\-ー─]*：/$1$2：/;	# 990102a
	s/（[ 	]*[0-9０-９\.．\-ー─]*(章|節+|付録)：/（$1：/g;		# 000211b, 000718d
	s/（[ 	]*[0-9０-９\.．\-ー─]*(章|節+|付録)(\*|\$\\ast\$|＊)：/（$1$2：/g;		# 210701
	s/（[ 	]*(定理|補題|証明)[0-9０-９\.．\-ー─]*：/（$1：/g;		# 000211b, 000718d
	s/（[ 	]*\"[0-9０-９\.．\-ー─]*\"(章|節+|付録)：/（$1：/g;	# 000213a, 000718d
	s/（[ 	]*\"[0-9０-９\.．\-ー─]*\"(章|節+|付録)(\*|\$\\ast\$|＊)：/（$1$2：/g;	# 210701
	s/（[ 	]*(定理|補題|証明)\"[0-9０-９\.．\-ー─]*\"：/（$1：/g;	# 000213a, 000718d
	$_=$_."\n";
}



#括弧の対応が１行単位なので$...$の中で括弧の対応をとる, 981119b, end"
# 1行の $ の数が奇数のとき Warning を出す(begin), 980924
#&dollarCheck;
sub	dollarCheck{
	$tmp = tr/\$//;	$tmp1=$tmp;
	while($tmp>1){
		$tmp -= 2;
	}
	if( $tmp==1 ){
		s/\$/\$\$/;	# $を１個付け加える

		&getLineNum;	&print_warning("% txt2tex Warning\(".$LineNum."\)\:１行に \$ が".$tmp1."個あります。偶数にしてください。\n");
		&insrt_matoato_warning($LineNum,"１行に \$ が".$tmp1."個あります。偶数にしてください。");
	}
}
# 1行の $ の数が奇数のとき Warning を出す(end)





#------ 章，節，節節の処理(begin) ---------
#初期設定 980916
sub init_section{
	&init_debug_eqn;
}

sub section{
	# 章などの処理
	s/^($H_LineNum)章：(.*)/\\section\{$2\} /;			#perl580bug: /^$H_LineNum章：/:NG, /^($H_LineNum)章：/:OK
	s/^($H_LineNum)節節：(.*)/\\subsubsection\{$2\} /;	#perl580bug: /^$H_LineNum章：/:NG, /^($H_LineNum)章：/:OK
	s/^($H_LineNum)節節節：(.*)/\\subsubsubsection\{$2\} /;	#perl580bug: /^$H_LineNum章：/:NG, /^($H_LineNum)章：/:OK
	s/^($H_LineNum)節：(.*)/\\subsection\{$2\} /;		#perl580bug: /^$H_LineNum章：/:NG, /^($H_LineNum)章：/:OK
	s/^($H_LineNum)章(\*|\$\\ast\$|＊)：(.*)/\\section*\{$3\} /;			# 210701
	s/^($H_LineNum)節節(\*|\$\\ast\$|＊)：(.*)/\\subsubsection*\{$3\} /;	# 210701
	s/^($H_LineNum)節節節(\*|\$\\ast\$|＊)：(.*)/\\subsubsubsection*\{$3\} /;	# 211001
	s/^($H_LineNum)節(\*|\$\\ast\$|＊)：(.*)/\\subsection*\{$3\} /;		# 210701
	s/^($H_LineNum)付録：(.*)/\\appendix\{$2\} /;		#perl580bug: /^$H_LineNum章：/:NG, /^($H_LineNum)章：/:OK
}

	# 行番号を削除LineNum, 980925
sub	rm_LineNum{
	s/^([ 	　]*)($H_LineNum)/$1/;
	s/^(	\&\& )($H_LineNum)/$1/;
}

	# print Warning line
sub	print_OUT_warning{
	if( s/^$H_nextComp(\% txt2tex Warning\()/$1/ ){	$H_OUT=$_;	&print_OUT;	next;}
}
#------ 章，節，節節の処理(end) ---------


#------ debug (begin) --------
sub init_debug_eqn{
	$fdebug_eqn = 0;	# \begin{eqnarray} ... \end{eqnarray} の中のときセット
	$fdebug_eqn2 = 0;	# \begin{array} ... \end{array} の中のときセット
	$fdebug_eqn3 = 0;	# 前の行に // があったときセット
}

sub check_debug_eqn{
	if( /\\begin\{eqnarray\}/ ){
		$fdebug_eqn = 1;
	}elsif( /\\end\{eqnarray\}/ ){
		$fdebug_eqn = 0;
	}

	if( /\\begin\{array\}/ ){
		$fdebug_eqn2 = 1;
	}elsif( /\\end\{array\}/ ){
		$fdebug_eqn2 = 0;
	}
}

sub debug_eqn{
	&check_debug_eqn;

	# 980916 式の中の改行のみの行を削除する(LaTeXでエラーが出る）(begin)
	if( $fdebug_eqn==1 ){
		if( /^[ 	　]*$/ ){
			next;
		}
	}
	# 980916 式の中の改行のみの行を削除する(LaTeXでエラーが出る）(end)

	# debug 980916 行列の中だけ , を & に変換するようにした(begin)
	if( $fdebug_eqn2==1 ){
		if( !(/^[ 	]*\%/) ){
			s/[ 	　]*,[ 	　]*/	& /g;
			s/：/\\vdots /g;		# 000211c,000530b
			s/・\./\\ddots /g;	# 000211c,000530b
			s/\\cdot \./\\ddots /g;	# 000519c,000530b
		}
	}
	# debug 980916 行列の中だけ , を & に変換するようにした(end)

	if(0){#000509b
		# debug 980916 &=&, &:& のバグをとる(begin), # 981205c修正
		#print $fdebug_eqn.$fdebug_eqn2.$fdebug_eqn3."---------".$_;
		if( $fdebug_eqn==1 ){
			if( $fdebug_eqn2==0 ){
				if( /\\\\/ || /\\begin\{array\}/ ){
					$fdebug_eqn3 = 1;
				}
				# if(!(s/^([ 	]*$H_LineNum)/$1($fdebug_eqn2)($fdebug_eqn3)XX/)){ s/^([ 	]*)/$1($fdebug_eqn2)($fdebug_eqn3)XX/};
				if( $fdebug_eqn3==1 ){
					if( /\&\=\&/ || /\&≡\&/ || /\&≠\&/ || /\&∝\&/ || /\&＝\&/ || /\&\>\&/ ||/\&\<\&/ ||/\&＜\&/ ||/\&＞\&/ ||/\&≧\&/ ||/\&≦\&/ ||/\&\:\&/ ){	# 000218b
						$fdebug_eqn3 = 0;
					}elsif( !( /\\begin/ || /\\\\/  || /\\label/ || /\\nonumber/ ) ){
						# if( !/\&/ ){	# 000219a
						if( !(/\&/)){ # 200624 debug未エラー出そう
							if( !(s/[ 	　]*([\=≡≠∝＝])[ 	　]*/	&$1& /) ){			# &=&, &:&, && をつける, 処理の順番を変更 981121b 000218b
								if( !(s/[ 	　]*([\>\<＜＞≧≦])[ 	　]*/	&$1& /) ){	# 000218b
									if( !(s/[ 　]*\:[ 　]*/ &\:& / ) ){
										# 000218b s/^([ 	]*)($H_LineNum)/$1$2\&\&/;
										s/^([ 	]*)($H_LineNum)/$1$2\&\&/;
									}
								}
							}
						}
						$fdebug_eqn3 = 0;
					}
				}
			}
		}else{
			$fdebug_eqn3 = 1;
		}
		# debug 980916 &=&, &:& のバグをとる(end)
	}#000509b

	# debug 980920	\left. \right)→), \left(\right.→(   (begin)
	#	s/\\left\.[ 	　]*\\right//g;
	#	s/\\left[ 	　]*([\[|\{|\(|\||\\\|])[ 	　]*\\right[ 	　]*\./$1/g;
	# debug 980920	\left. \right)→), \left(\right.→(   (end)

	# $a$ $a が$$$a$ $a$ になるバグをとる(begin), 980924
	# $$ を $ にする

	while( /\$\$/ ){	s/\$\$/\$/g;}
	# $a$ $a が$$$a$ $a$ になるバグをとる(end)
}
#------ debug (end) --------


#	●\varphi (s), \maxが$$に入らない：\varphi $\left(s\right)$ → $\varphi \left(s\right)$, 000213d
sub	debug000213d{
	chop;
	$_tmp = '';
	$f = 0;
	while( s/\$(.*)$// ){
		$_tmp1 = $1;
		if( $f==0 ){	$f = 1;
			for($i=0;$i<=$#def_tex_hensuu;$i++ ){
				$_tmp3 = "\\".$def_tex_hensuu[$i];
				s/($_tmp3)([^a-zA-Z])/\$$1\$$2/g;
				s/($_tmp3)$/\$$1\$/g;
			}
			s/\\(varphi|Pi|epsilon|vartheta|varpi|varsigma|max|min|lim|int)([^a-zA-Z])/\$\\$1\$$2/g;
			s/\\(varphi|Pi|epsilon|vartheta|varpi|varsigma|max|min|lim|int)$/\$\\$1\$/g;
		}else{			$f = 0;}
		$_tmp = $_tmp.$_.'$';	$_ = $_tmp1;
	}
	$_ = $_tmp.$_."\n";
	s/\$([ 	]*)\$/$1/g;
}


#	●表：で$a  \\$はjlatex error(問題なくdviファイルはできるが)なので$a$	\\に修正, 000212d, dollarに移動000504g
#sub	debug_tbl{
#	if( /\\begin\{table/ ){	$fHyou = 1;}
#	if( /\\end\{table/ ){	$fHyou = 0;}
#	if( $fHyou==1 ){
#		s/\$([ 	]*\\\\)\$/$1/o;
#		s/([ 	]*\\\\)\$/\$$1/o;
#	}
#}

#------ 終了処理(begin) ---------
sub getENDING{
	$H_OUT= <<"ENDING";


\\end{document}
ENDING
	&print_OUT;
}
#------ 終了処理(end) ---------





#------------------------------------
#	無変換処理 "aaa" (begin)
#------------------------------------
# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換えて、囲まれた文字列をignor.datに書く
#	　"あああ"
# 無変換""の仕様：
#	1: "文字列" の中の文字列をTeXに変換しない
#	2:ignor処理の入れ子の書き方
#			"Title is ”iMac”."
#		→	Title is "iMac".
#	980902

#初期設定

sub	init_verbatim{
	@ptnIgnor = //;		# 無変換の文字列

	$nIgnor = 0;		# 無変換のインデックス
	$f_verbatim=0;		# \begin{verbatim}から\end{verbatim}までの行を"で囲う
	$f_verb=0;			# \verb'aa \n a'のように２行以上にまたがるときオン

	$ptn_verb='';		# \verb'aa \n a'のように２行以上にまたがるとき、'を記憶
}

#	&verbatim;	# \begin{verbatim}から\end{verbatim}までの行を"で囲う(begin)980922
sub	verbatim{
	my	($_tmp);
	if( $f_verbatim==0 && s/(\\begin\{verbatim\}.*\\end\{verbatim\})/\/\*$nIgnor\*\// ){ # 000206c
		$ptnIgnor[$nIgnor] = $1;
		$nIgnor++;
	}elsif( $f_verbatim==0 && s/(\\begin\{verbatim\}.*)$/\/\*$nIgnor\*\// ){
		$ptnIgnor[$nIgnor] = $1;
		$nIgnor++;
		$f_verbatim=1;
	}elsif( s/^([ 	　]*)($H_LineNum)(.*)(\\end\{verbatim\})/$H_next\/\*$nIgnor\*\// ){	# 981205b 000430c
		if( $f_verbatim==1 ){
			$ptnIgnor[$nIgnor] = $1.$3.$4;
			$nIgnor++;
			$f_verbatim=0;
		}else{
			$ptnIgnor[$nIgnor] = $1.$3;
			$nIgnor++;
			$f_verbatim=0;
			$_tmp = $_;	$_ = $2;
			&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'): \\begin{verbatim}がないのに\\end{verbatim}があるので無視しました。'."\n");
			&insrt_matoato_warning($LineNum,'\\begin{verbatim}がないのに\\end{verbatim}があるので無視しました。');
			$_ = $_tmp;
		}
	}elsif( $f_verbatim==1 ){
		s/^([ 	　]*)($H_LineNum)/$1/;	# 000430c
		s/^(.*)$/$H_next\/\*$nIgnor\*\//;
		$ptnIgnor[$nIgnor] = $1;
		$nIgnor++;
	}
}
#	&verbatim;	# \begin{verbatim}から\end{verbatim}までの行を"で囲う(end)


#初期設定

#	&verb新規作成...\verbの次の１文字から、次に現れるまで"で囲う(begin), 000206b
sub	verb{
	if( $f_verb ){	# 前の行が\verb'aa \n a'のように２行以上にまたがっていたとき
		if( s/($H_LineNum)([^$ptn_verb]*)$ptn_verb(.*)/$1\/\*$nIgnor\*\/$3/ ){
			$ptnIgnor[$nIgnor] = $2.'|';
			$nIgnor++;
			$f_verb  = 0;
		}else{
			$ptnIgnor[$nIgnor] .= $_;
		}
	}

	if( $f_verb == 0 ){	# 前の行が\verb|aa \n a|のように２行以上にまたがっていなかったとき
		$_tmp = '';
		while( s/\\verb(.)(.*)$// ){
			$_tmp = $_tmp.$_.'/*'.$nIgnor.'*/';
			$ptn_verb = '\\'.$1;	$_ = $2;
			if( s/([^$ptn_verb]*)$ptn_verb(.*)/$2/ ){
				$ptnIgnor[$nIgnor] = '\\verb|'.$1.'|';
				$nIgnor++;
			}else{
				$ptnIgnor[$nIgnor] = '\\verb|'.$_;
				$nIgnor++;
				$f_verb  = 1;
			}
		}
		if( $f_verb==0 ){	$_ = $_tmp.$_;}
		else{				$_ = $_tmp;}
	}
}
#	&verb新規作成...\verbの次の１文字から、次に現れるまで"で囲う(end), 000206b


# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換える(begin)
sub	getIgnor{
	my	($tmp);

	&getIgnor_double_quotation;	#000504j

	#980919 bug  :	\caption{磁石（{m_{agne}} \left.\right)}
	#が下の下の処理で:	/*8*/{磁石（{m_{agne}} \left.\right)}
	#になる．先頭がタブなのでeqnarray環境と判断されて$(dollar)が処理されない	
	#	解決策：タブも含めて無変換（/*8*/）にする

	if( s/(^	[	 　]*\\caption\{)/\/\*$nIgnor\*\// ){
			$ptnIgnor[$nIgnor] = $1;
			$nIgnor++;
			s/(\})/\/\*$nIgnor\*\//;
			$ptnIgnor[$nIgnor] = $1;
			$nIgnor++;
	}
	# \caption{磁石（${m_{agne}} \left.\right)}$

	if(1){
		# 本文中のa+\limなどがa+/*1*/に変換され、$a+$\limと$$の中から外れる→/*1*/に変換するコマンドを限定する, 000504j
		$tmp = 'clearpage|newpage|centering|onecolumn|twocolumn|hline|Huge|huge|LARGE|Large|large|normalsize|small|footnotesize|scriptsize|tiny|it|gt|tt|bf';
		while( s/\\($tmp)([^a-zA-Z0-9])/\/\*$nIgnor\*\/$2/ ){	$ptnIgnor[$nIgnor] = "\\".$1;	$nIgnor++;}
		while( s/\\($tmp)$/\/\*$nIgnor\*\// ){	$ptnIgnor[$nIgnor] = "\\".$1;	$nIgnor++;}
		$tmp = 'begin|end|fbox|underline|vspace|hspace|mbox|hbox|input';
		while( s/\\($tmp)[ 	]*\{[ 	\\]*[ 	a-zA-Z0-9]+\}/\/\*$nIgnor\*\// ){	$ptnIgnor[$nIgnor] = $&;	$nIgnor++;}
	}else{
		# 980918 \begin{eqnarray} などを無変換にする(begin)
		#\begin{eqnarray} \vspace{10pt}
		while(/\\[a-zA-Z]/){
			if( s/(\\[a-zA-Z][a-z]*[ 	]*[\{\[][ a-zA-Z0-9]*[\}\]][\{\[][ 	]*[\{\[][ a-zA-Z0-9]*[\}\]])/\/\*$nIgnor\*\// ){
				$ptnIgnor[$nIgnor] = $1;
				$nIgnor++;
			}elsif( s/(\\[a-zA-Z][a-z]*[ 	]*[\{\[][ a-zA-Z0-9]*[\}\]])/\/\*$nIgnor\*\// ){
				$ptnIgnor[$nIgnor] = $1;
				$nIgnor++;
			}elsif( s/(\\[a-zA-Z][a-z]*)/\/\*$nIgnor\*\// ){
				$ptnIgnor[$nIgnor] = $1;
				$nIgnor++;
				# }elsif( s/(\\\\)/\/\*$nIgnor\*\// ){
					# $ptnIgnor[$nIgnor] = $1;
					# $nIgnor++;
			}
			# if( s/(\\[a-zA-Z][a-z]*\{[ a-zA-Z0-9]*\})/\/\*$nIgnor\*\// ){
		}
		# 980918 \begin{eqnarray} などを無変換にする(end)
	}


	# const. を無変換にする(begin), 980924
	while( s/(\W)(const\.)(\W)/$1\/\*$nIgnor\*\/$3/ ){
		$ptnIgnor[$nIgnor] = $2;
		$nIgnor++;
	}
	# const. を無変換にする(end)


	# \$ を無変換にする,(begin) 000625j,000625k
	$_=" ".$_;
	while( s/([^\\])(\\[\$\~])/$1\/\*$nIgnor\*\// ){
		$ptnIgnor[$nIgnor] = $2;
		$nIgnor++;
	}
	s/^.//;
	# $ を無変換にする(end)

	# $ を無変換にする（ " のなくなった最後に処理すべき..."$a=b$"が変になる）(begin), 980924
	while( s/(\$)/\/\*$nIgnor\*\// ){
		$ptnIgnor[$nIgnor] = $1;
		$nIgnor++;
	}
	# $ を無変換にする（ " のなくなった最後に処理すべき..."$a=b$"が変になる）(end)
}

#------- ""で囲まれた文字列を/*1*/に変換する000504j
sub	getIgnor_double_quotation{
	my	($tmp, $tmp0, $aft_, @ptn);

	if( $tmp = tr/\"// ){
		$tmp0 = $tmp;
		while( $tmp0>0 ){	# "が偶数でないときエラーメッセージを書く
			$tmp0 -= 2;
			if( $tmp0 == -1 && $step_number == 2.5){
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):１行に " が'.$tmp."個あります。偶数にしてください。\n");
				&insrt_matoato_warning($LineNum,'１行に " が'.$tmp.'個あります。偶数にしてください。');
			}
		}

		$aft_ = '';
		chop;
		# while( @ptn = /^(.*)\"(.*)\"(.*)$/ ){
		while( @ptn = $_ =~ /^(.*)\"(.*)\"(.*)$/ ){ # 200624
		# while( @ptn =~ /^(.*)\"(.*)\"(.*)$/ ){ # 200624 debug未==>× そもそも@ptnはこのサブルーチンで宣言されてるから常に存在しないのでは？ ==> 全く違う。@ptnに正規表現にマッチしたやつを格納する。この場合 @ptn = $_ =~ /^(.*)\"(.*)\"(.*)$/ と同義
			#print $aft_;print "\n";
			#print $tmp."	0	".$ptn[0]."	1	".$ptn[1]."	2	".$ptn[2]."\n";
			$_ = $ptn[0];
			$ptnIgnor[$nIgnor] = $ptn[1];
			if( $ptnIgnor[$nIgnor]=~/\\begin/ && $ptn[2]=~/[^ 	]*\// ){	# /*1*/a/b のとき000625e
				$aft_ = '/*'.$nIgnor.'*/ '.$ptn[2].$aft_;
			}else{
				$aft_ = '/*'.$nIgnor.'*/'.$ptn[2].$aft_;
			}
			$nIgnor++;
		}
		$_ = $_.$aft_."\n";
		# print;
	}
}
# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換える(end)



# ダブルクォーテーション"で囲まれた文字列をignor.datに書く(begin)
#	●ignor処理の入れ子ができるようにする, 981123a
#			"Title is ”iMac”."
#		→	Title is "iMac".
sub	writeIgnor{
	open(IGNOR,">:utf8","ignor.dat");	# 箇条書きの参照ラベルのファイルへの出力（あとで参照処理で使う）
	# binmode IGNOR, ":encoding(cp932)";
	print IGNOR encode("utf8","	\/\*ダブルクォーテーション\"で囲まれた無変換の文字列一覧\*\/\n");
	# for($i=0;$i<$nIgnor;$i++){
		# print IGNOR $ptnIgnor[$i]."\n";
	# }
	$_tmp = $_;
	for($i=0;$i<$nIgnor;$i++){
		$_ = $ptnIgnor[$i];
		# 000502c		s/”/\"/g;
		$ptnIgnor[$i] = $_;
		print IGNOR encode("utf8",$_."\n");
	}
	$_ = $_tmp;
	close(IGNOR);
}
# ダブルクォーテーション"で囲まれた文字列をignor.datに書く(end)




# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換えた文字列をignor.datから読み込んで元に戻す。
#	　"あああ"
# 無変換""の仕様：
#	1: "文字列" の中の文字列をTeXに変換しない
#	980902


# ダブルクォーテーション"で囲まれた文字列をignor.datから読む(begin)
sub	readIgnor{
	open(IGNOR,"<:utf8","ignor.dat");	# 箇条書きの参照ラベルのファイルへの出力（あとで参照処理で使う）
	# binmode IGNOR, ":encoding(cp932)";
	@ptnIgnor = //;	$nIgnor = 0;
	$f = 0;	# 1のときignorの行
	while(<IGNOR>){
		chop;
		# if( /^	/o ){
		if( /^	\/\*ダブルクォーテーション\"で囲まれた無変換の文字列一覧\*\//o ){
			$f = 1;
			next;
		# }else{
			# $f = 0;
		}
		# }
		if( $f==1 ){ # 無変換 ignor の抽出
			$ptnIgnor[$nIgnor] = $_;
			$nIgnor++;
		}
	}
	close(IGNOR);
	# for($i=0;$i<$nIgnor;$i++){print $ptnIgnor[$i]."\n";}
}
# ダブルクォーテーション"で囲まれた文字列をignor.datから読む(end)



# 参照ラベルとダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換えた文字列を元に戻す。(begin)
#	while( s/\/\*([0-9]*)\*\//$ptnIgnor[$1]/ ){}
# \alpha/*10*/ --> \alphaAPPLE (bug) --> \alpha APPLE とする000801f
sub	putIgnor{
	my	($new, $ptn);
	chop;	$new = '';
	while( s/(.*)\/\*([0-9]*)\*\/// ){
		$new=$_;	$ptn=$ptnIgnor[$2];	$_=$1;
		if( /[^\\]\\[a-zA-Z0-9\_]+$/ && $ptn=~/^[a-zA-Z0-9]/ ){	$ptn=" ".$ptn;}
		$_=$_.$ptn.$new;
	}
	$_=$_."\n";
	if(/\/\*[0-9]/){print "txt2tex error in putIgnor:".$_;}
}
# ダブルクォーテーション"で囲まれた文字列をTeXに変換しないように、/*1*/で置き換えた文字列を元に戻す。(end)


#------------------------------------
#	無変換処理 "aaa" (end)
#------------------------------------



#------------------------------------
#	箇条書きをTeXに変換(begin)
#------------------------------------

#箇条書きをTeXに変換 新規全面書き直し110811a
#仕様：
#	1: /^\t　/のとき箇条書き
#	2:箇条書きの記号（・,●,1.,A1,1)など）は	　からスペース 　または右括弧)]}まで
#		ex.	　A1 あああ
#		ex.	　・ あああ
#		ex.	　A1)あああ
#	未3:箇条書きの入れ子は/^\t　　/。　が増える分だけ入れ子OK
#	未4:箇条書きの中の式とそのあとの文章を箇条書きとして処理できる．（空行があると箇条書き終了）
#	旧バージョンの自動番号割付とラベルは10年間不要だったのでヤメ。とにかくtxtに書いたそのままをシンプルにtexにする！
#箇条書きをTeXに変換(begin)
sub	list2tex{
	my	(@ptn, $_tmp);

	if( $fItem==0 && /^	　/ ){	# 箇条書きの始まり
		$fItem=1;	$H_OUT="%\n".$H_next.'\begin{itemize}'."\n";	&print_OUT_euc;
	}
	if( $fItem==1 && /^	　/ ){	# 箇条書きの中身
		s/^	　($H_LineNum)/$1    /;
		if(		s/^($H_LineNum    )([・○●◎※◇□△▽☆★●◆■▲▼◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ]+)/$1"\\item\["$2"\]" / ){
		}elsif(	s/^($H_LineNum    )([a-zA-Zａ-ｚＡ-Ｚ0-9０-９]*[\:\;\.\,．])/$1"\\item\["$2"\]" / ){
		}elsif(	s/^($H_LineNum    )([^ 　\)\]）］あ-んア-ン]*[ 　\)\]）］])// ){
			$_tmp[0]=$1;	$_tmp[1]=$2;	$_tmp[1]=~s/[ 　]//g;	$_=$_tmp[0].'"\item["'.$_tmp[1].'"]" '.$_;
		}else{
			s/^($H_LineNum)(    )/$1$2"\\item "/;
		}
	}elsif( $fItem==1 && !(/^	　/) ){	# 箇条書きの終わり
		$fItem=0;	$H_OUT=$H_next.'\end{itemize}'."\n";	&print_OUT_euc;
	}
}
#箇条書きをTeXに変換(end)


#以下、旧バージョン
#	　あああ
#箇条書きの仕様：
#	1: /^\t　/のとき箇条書き
#	2:/^\t　([a-zA-Z]*)([0-9]*)(.)(.*)/のときラベルA1などをつける．参照は（a1）でする．
#		ex.	　A1:あああ
#	3:/^\t　([a-zA-Z]*)(.)(.*)/のときラベルなし．
#		ex.	　・あああ
#	4:箇条書きの中の式を処理できる．
#	980831

#箇条書きをTeXに変換
#	　あああ
#箇条書きの仕様：
#	1: /^\t　/のとき箇条書き
#	2:/^\t　([a-zA-Z]*)([0-9]*)(.)(.*)/のときラベルA1などをつける．参照は（a1）でする．
#		ex.	　A1:あああ
#	3:/^\t　([a-zA-Z]*)(.)(.*)/のときラベルなし．
#		ex.	　・あああ
#	4:箇条書きの中の式を処理できる．
#	980831

#初期設定

sub	initList2tex{
	$fItem = 0;		# 箇条書きの行のとき(1),でないとき(0) 
	@ptnItem = //;	# 箇条書きの参照ラベル(A1など）
	$nItem = 0;		# 箇条書きの参照ラベルのインデックス
	$fnItem = 0;	# 箇条書きの参照ラベルのインデックスがあるとき1
	$modeItem = 1;	# 0:参照ラベルなし、1:A1などのみ参照ラベルあり(default)、2:1とA1に参照ラベルつける

}




#箇条書きをTeXに変換(begin)
sub	list2texOld{
	my	(@ptn, $_tmp);

	if( /^	/o && !(/表：/o || /図：/o) && $fHyou==0 && $fMatKaigyou==0 ){ # 式の抽出, 981118,000527d
	  if( s/^	　[ 	]*/	/o || /^	  ($H_LineNum)([a-zA-Zａ-ｚＡ-Ｚ]*)([0-9０-９]*)([\:\;\.\,．\)\}\]）｝」。・，○●◎○◇□△▽☆★●◆■▲◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ])(.*)/ ){	# 981118, 000504e, 000707u,030825a
		chop;
		s/(　+)($H_LineNum)/$2$1/;	#000813l
		@ptn=/^	[ 	]*($H_LineNum)([a-zA-Zａ-ｚＡ-Ｚ]*)([0-9０-９]*)([\:\;\.\,．\)\}\]）｝」。・，○●◎○◇□△▽☆★●◆■▲▼◎◯〇①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ]*)(.*)$/;	# 981121e, 000504e,030825a
		#for($i=0;$i<5;$i++){print $ptn[$i]."	-";}print "\n";#print;
		# 1- 2- 3- 4 
		#  -　-　-      -------
		#  -　-　-      -------
		#  -　-・-あああ-------
		#  -　-・-いいい-------
		#  -１-．-あああ-------
		#  -２-．-いいい-------
		# A- 1-: -あああ-------
		# A- 2-: -いいい-------
		#Ａ-１-．-あああ-------
		#Ａ-２-．-いいい-------
		# 箇条書きの先頭が i), ii) などの数字なしのときはラベルなしとして扱う, 981119h, begin
		if( length($ptn[2])==0 ){
			$ptn[4] = $ptn[1].$ptn[2].$ptn[3].$ptn[4];
			$ptn[1]='';	$ptn[2]='';	$ptn[3]='';
		}
		# 箇条書きの先頭が i), ii) などの数字なしのときはラベルなしとして扱う, 981119h, end
		if( $#ptn>1 ){
			$_ = $ptn[0]."	".$ptn[4]."\n";
		}else{
			s/^	　/	/;
		}
		if( length($ptn[1])>0 || length($ptn[2])>0 ){
			if( $modeItem==2 ){
				$ptnItem[$nItem] = &repl_label_moji($ptn[1].$ptn[2]);	$nItem++;
				$fnItem = 1;
			}elsif( $modeItem==1 ){
				if( length($ptn[1])>0 ){
					if( s/[ 	]*（[ 	]*([^）]*)[ 	]*）[ 	]*$// ){		# 000210e
						$_tmp = $_;	$_ = $1;	s/\"//g;
						$ptnItem[$nItem] = &repl_label_moji($_);	$nItem++;
						$fnItem = 1;	$_ = $_tmp;
					}else{
						$ptnItem[$nItem] = &repl_label_moji($ptn[1].$ptn[2]);	$nItem++;
						$fnItem = 1;
					}
				}else{
					$fnItem = 0;
				}
			}elsif( $modeItem==0 ){
				$fnItem = 0;
			}else{
				&print_warning("bug or error: value of \$modeItem is abnormal\n");
				&insrt_matoato_warning($LineNum,"bug or error: value of \$modeItem is abnormal");
				$fnItem = 0;
			}
		}else{
			$fnItem = 0;
		}
		# print OUT $H_next."XXX",$_;"
		if( $fItem==0 ){	# はじまりの処理
			$fItem = 1;
			if( length($ptn[2])>0 ){
				$ptn[2] = '\arabic{enumi}';
			}else{
				$ptn[2] = '';
			}
			$H_OUT=$H_next.'\begin{enumerate}'."\n";
			$H_OUT=$H_OUT.$H_next.'	\renewcommand{\labelenumi}{'.$ptn[1].$ptn[2].$ptn[3].'}'."\n";
			$H_OUT=$H_OUT.$H_next.'	\item'."\n";	&print_OUT_euc;	#981118
		}else{				# 中間の処理
			if( $fnItem==1 ){
				$H_OUT=$H_next.'       	\label{'.$ptnItem[$nItem-2].'}'."\n";	&print_OUT_euc;
			}else{
				$H_OUT=$H_next.'       	\nonumber'."\n";	&print_OUT_euc;#110806a
			}
			$_ = $H_next.'	\item'."\n".$_;		#981118
		}
	  }	# 981118
	}else{
		if( $fItem==1 ){	# おわりの処理
			$fItem = 0;
			if( $fnItem==1 ){
				$H_OUT=$H_next.'       	\label{'.$ptnItem[$nItem-1].'}'."\n";	&print_OUT_euc;
			}else{
				# $H_OUT=$H_next.'       	\nonumber'."\n";	&print_OUT_euc;
				# $H_OUT=$H_next.."\n";	&print_OUT_euc;#110806a
			}
			$H_OUT=$H_next.'\end{enumerate}'."\n";	&print_OUT_euc;
			$fnItem = 0;
		}
	}
}
#箇条書きをTeXに変換(end)

# 箇条書きの参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelItem{
	print LABEL encode("utf8","	箇条書きの参照ラベル一覧\n");
	for($i=0;$i<$nItem;$i++){
		print LABEL encode("utf8",$ptnItem[$i]."\n");
	}
}
# 箇条書きの参照ラベルのファイルへの出力（あとで参照処理で使う）(end)

#------------------------------------
#	箇条書きをTeXに変換(end)
#------------------------------------





#------------------------------------
#	式、図、表、箇条書きの参照ラベルを TeX に変換する(begin) lab2tex.pl
#------------------------------------
#式、図、表、箇条書きの参照ラベルを TeX に変換する

#参照ラベルの仕様：
#	1:書き方（A1）のように全角小カッコで囲む 
#箇条書き参照ラベルの仕様：
#	1:（A1）をTeXで A1 と表示させる。... A\ref{A1}
#	980901

#初期設定

sub	initLabel2tex{
	@ptnItem = //;	# 箇条書きの参照ラベル(A1など）
	$nItem = 0;		# 箇条書きの参照ラベルのインデックス
	@sectionLabel = //;	$nSection = 0;		# 章，節，節節，付録番号 980923

	@multiply_defined_label = //;	#多重定義されたラベル000723e
	@n_multiply_defined_label = //;	#多重定義された回数000723e
}


# 図，表，式，箇条書き，参考文献の参照ラベルの一覧ファイルの読込(begin)
sub	readLabel{
	open(ITEM,"<:utf8","label.dat");	# 図，表，式，箇条書き，参考文献の参照ラベルの一覧ファイル
	# binmode ITEM, ":encoding(cp932)";


	#初期設定

	@figLabel = //;	$nFig = 0;		# 図番号
	$mFig=0;

	@tblLabel = //;	@captionTbl = //;	$nHyou = 0;	# 表番号
	$mTbl=0;

	@eqLabel = //;	$numEq = 0;		# 式番号
	$mEqn=0;

	@ptnItem = //;	$nItem = 0;		# 箇条書き
	$mItem=0;
	
	@ptnBib = //;	$nBib = 0;		# 参考文献番号
	$mBib=0;

	@sectionLabel = //;	$nSection = 0;		# 章，節，節節，付録番号 980923
	$mSection=0;

	@subFigLabel = //;	$nsubFig1 = 0;		# subfig番号(重複確認にしか使用しない) 200624
	$msubFig = 0;

	while(<ITEM>){
		chomp;
		if( /^	/o ){
			if( /図/o ){ 		# 図番号の抽出
				$mFig = 1;
				if( /複/o){
					$msubFig = 1;
				}else{
					$msubFig = 0;
				}
			}else{
				$mFig = 0;
			}
			if( /表/o ){ 		# 表番号の抽出
				$mTbl = 1;
			}else{
				$mTbl = 0;
			}
			if( /式/o ){ 		# 式番号の抽出
				$mEqn = 1;
			}else{
				$mEqn = 0;
			}
			if( /箇条書き/o ){	# 箇条書きの抽出
				$mItem = 1;
			}else{
				$mItem = 0;
			}
			if( /参考文献/o ){	# 参考文献番号の抽出
				$mBib = 1;
			}else{
				$mBib = 0;
			}
			if( /章/o ){	# 章，節，節節，付録番号 980923
				$mSection = 1;
			}else{
				$mSection = 0;
			}
		}else{
			if( ($mFig==1) && ($msubFig==0) ){		# 図番号の読み込み
				$figLabel[$nFig] = $_;
				$nFig++;
			}elsif( $mTbl==1 ){	# 表番号の読み込み
				# 000212a		$captionTbl[$nHyou] = $_;
				$tblLabel[$nHyou] = $_;
				$nHyou++;
			}elsif( $mEqn==1 ){	# 式番号の読み込み
				$eqLabel[$numEq] = $_;
				$numEq++;
			}elsif( $mItem==1 ){# 箇条書きの読み込み
				$ptnItem[$nItem] = $_;
				$nItem++;
			}elsif( $mBib==1 ){	# 参考文献番号の読み込み
				$ptnBib[$nBib] = $_;
				$nBib++;
			}elsif( $mSection==1 ){	# 章，節，節節，付録番号 980923
				$sectionLabel[$nSection] = $_;
				$nSection++;
			}elsif( ($mFig==1) && ($msubFig==1)){ # subfig番号の読み込み(重複確認にしか使用しない) 200624
				$subFigLabel[$nsubFig1] = $_;
				$nsubFig1++;
			}
		}
	}
	close(ITEM);
	# for($i=0;$i<$nFig;$i++){print $figLabel[$i]."\n";}
	# for($i=0;$i<$nHyou;$i++){print $captionTbl[$i]."\n";}
	# for($i=0;$i<$numEq;$i++){print $eqLabel[$i]."\n";}
	# for($i=0;$i<$nItem;$i++){print $ptnItem[$i]."\n";}
	# for($i=0;$i<$nBib;$i++){print $ptnBib[$i]."\n";}
}
# 図，表，式，箇条書き，参考文献の参照ラベルの一覧ファイルの読込(end)



# 図，表，式，箇条書き，参考文献の参照ラベルをTeXに変換(begin)
sub	label2tex{
	my	($new_, $bef_, $ptn, $tmp_, $f, $ptnNew, $i, $ptnTmp, $ptnOrg,$tmp,$j,$nref);
	$new_ = '';
	while( s/^(.*)）(.*)$/$1/ ){ # 参照ラベルの抽出
		$new_ = $2.$new_;

		s/^(.*)（(.*)$/$1/;
		$bef_ = $1;
		$ptnOrg = $2;	# （）の中身
		$tmp_ = $_;	$_ = $ptnOrg;	s/\"//g;	$ptn=$_;	$_=$tmp_;	# 990102c begin

		#---- （）の中身に /*1*/ があるときignor を元に戻す
		$tmp_=$_;	$_=$ptn;	s/\/\*([0-9][0-9]*)\*\//$ptnIgnor[$1]/g;	$ptn=$_;	$_=$tmp_;

		$f = 0;		# 処理済みフラグ：$f=1のとき次の行に

		if($C_subfile != 1){

			if( $f==0 ){			# 図の参照ラベル処理
				for( $i=0;$i<$nFig;$i++ ){
					if( $figLabel[$i] eq $ptn ){
						&checkLabel2($ptn);
						$ptnNew = "\"\\ref\{".$ptn."\}\"";
						$f = 1;
						last;
					}
				}
			}
			if( $f==0 ){			# 複図の参照ラベル処理 200624
				for($i=0;$i<$nsubFig2;$i++){
					$tmp = @{$subFigLabel1->[$i]};
					for($j=1;$j<$tmp;$j++){
						if($subFigLabel1->[$i][$j] eq $ptn){
							&checkLabel2($ptn);
							$ptnNew = "\"\\ref\{" . $subFigLabel1->[$i][0] . "\}\\subref\{" . $subFigLabel1->[$i][$j] . "\}\"";
							$f = 1;
							last;
						}
					}
				}
			}
			if( $f==0 ){			# 表の参照ラベル処理
				for( $i=0;$i<$nHyou;$i++ ){
					if( $tblLabel[$i] eq $ptn ){
						&checkLabel2($ptn);
						$ptnNew = "\"\\ref\{".$ptn."\}\"";
						$f = 1;
						last;
					}
				}
			}
			if( $f==0 ){			# 式の参照ラベル処理
				for( $i=0;$i<$numEq;$i++ ){
					if( $eqLabel[$i] eq $ptn ){
						&checkLabel2($ptn);
						$ptnNew = "\"\(\\ref\{".$ptn."\}\)\"";
						$f = 1;
						next;
					}
				}
			}
			if( $f==0 ){			# 箇条書きの参照ラベル処理
				for( $i=0;$i<$nItem;$i++ ){
					if( $ptnItem[$i] eq $ptn ){			# 000210e
						&checkLabel2($ptn);
						$ptnNew = '"\\ref{'.$ptn.'}"';	# 000210e
						$f = 1;
						last;
					}
				}
				$_ = $tmp_;
			}
			if( $f==0 ){			# 参考文献の参照ラベル処理
				# ----------------------------------------------------------------------------
				# old version ラベル抽出したやつだけ\citeする
				# ----------------------------------------------------------------------------
				# $tmp_ = $_;	$_ = $ptn;			s/ /　/g;					# 000213g
				# for( $i=0;$i<$nBib;$i++ ){
				# 	if( $ptnBib[$i] eq $_ ){	#000213g
				# 		&checkLabel2($_);
				# 		$ptnNew = '"\\cite{'.$_.'}"';	# 000213g
				# 		$f = 1;
				# 		last;
				# 	}
				# }
				# $_ = $tmp_;
				# ----------------------------------------------------------------------------
				# new version 201001 参：は全て\citeにする
				# ----------------------------------------------------------------------------
				$tmp_ = $_;	$_ = $ptn;		s/ /　/g;
				while(1){
					if( s/^参：([^,、]+)[,、]?// ){
						$f = 1;
						if($nref == 0){
							$ptnNew = '"\\cite{' . $1;
							$nref = 1;
						}elsif($nref == 1){
							$ptnNew .= "," . $1;
						}
					}else{
						if($nref == 1){
							$ptnNew .= '}"';
							$nref = 0;
							last;
						}else{
							last;
						}
					}
				}
				$_ = $tmp_;
			}
			if( $f==0 ){			# 章，節，節節，付録番号 980923
				for( $i=0;$i<$nSection;$i++ ){
					#注意： " を削除する

					$tmp_ = $_;	$_ = $ptn;
					s/\"//g;
					$ptnTmp = $_;
					$_ = $tmp_;
					if( $sectionLabel[$i] eq $ptnTmp ){
						&checkLabel2($ptnTmp);
						$ptnNew = '"\ref{'.$ptnTmp.'}"';
						$f = 1;
						last;
					}
				}
			}


			# （A1）のA1が参照ラベルにないとき無視する処理
			if( $f==0 ){
				$ptnNew = "（".$ptnOrg."）";	#000530k
			}

		}else{
			$tmp_ = $_;	$_ = $ptn;		s/ /　/g;
			while(1){
				if( s/^参：([^,、]+)[,、]?// ){
					$f = 1;
					if($nref == 0){
						$ptnNew = '"\\cite{' . $1;
						$nref = 1;
					}elsif($nref == 1){
						$ptnNew .= "," . $1;
					}
				}else{
					if($nref == 1){
						$ptnNew .= '}"';
						$nref = 0;
						last;
					}else{
						last;
					}
				}
			}
			for($i=0;$i<$nsubFig2;$i++){
				$tmp = @{$subFigLabel1->[$i]};
				for($j=1;$j<$tmp;$j++){
					if($subFigLabel1->[$i][$j] eq $ptn){
						&checkLabel2($ptn);
						$ptnNew = "\"\\ref\{" . $subFigLabel1->[$i][0] . "\}\\subref\{" . $subFigLabel1->[$i][$j] . "\}\"";
						$f = 1;
						last;
					}
				}
			}
			$_ = $tmp_;

			if($f==0){$ptnNew = "\"\\ref\{".$ptn."\}\"";}
		}

		$new_ = $ptnNew.$new_;
	}
	$bef_=~s/\\$/\\ /;	#000707x
	$_ = $bef_.$new_."\n";
}

#	多重定義されたラベルを参照されたら、１回だけ error message を出す, 000723e
sub	checkLabel2{
	my	($_org, $i);
	$_org=$_;	$_=$_[0];
	for( $i=0;$i<=$#multiply_defined_label;$i++ ){
		if( $n_multiply_defined_label[$i] > 0 && $multiply_defined_label[$i] eq $_ ){
			&print_warning('% txt2tex Error:'."ラベル \"".$_."\" が".$n_multiply_defined_label[$i]."重に定義・参照されてます\n");
			&insrt_matoato_warning($LineNum,"ラベル \"".$_."\" が".$n_multiply_defined_label[$i]."重に定義・参照されてます");
			$n_multiply_defined_label[$i] = 0;
			last;
		}
	}
	$_=$_org;
}
# 図，表，式，箇条書き，参考文献の参照ラベルをTeXに変換(end)

# 図，表，式，箇条書き，参考文献の参照ラベルのファイルへの出力（あとで参照処理で使う）
sub	writeLabel{
	open(LABEL,">label.dat");
	# binmode LABEL, ":encoding(cp932)";
	&writeLabelFig;		# 図番号の参照ラベルのファイルへの出力
	&writeLabelTbl;		# 表番号の参照ラベルのファイルへの出力
	&writeLabelEqn;		# 式番号の参照ラベルのファイルへの出力
	&writeLabelItem;	# 箇条書きの参照ラベルのファイルへの出力
	&writeLabelBib;		# 参考文献の参照ラベルのファイルへの出力
	&writeLabelSection;		# 章，節，節節，付録番号の参照ラベルのファイルへの出力 980923
	&writeLabelsubFig;	# 複図番号の参照ラベルのファイルへの出力

	close(LABEL);

	&checkLabel;
}

# 図，表，式，箇条書き，参考文献の参照ラベルの２重定義のチェック 980924
# 注意：\refを書くときに同時に２重定義のチェックをして（\refされてないラベルはエラーでないので無視）行番号を示したい。, 980925
sub	checkLabel{
	open(LABEL,"<:utf8","label.dat");
	# binmode LABEL, ":encoding(cp932)";
	@tmp000 = '';	$n000 = 0;
	while(<LABEL>){
		chomp;
		$f000=0;
		for($i=0;$i<$n000;$i++){
			if( $_ eq $tmp000[$i] ){	$f000=1;}
		}
		if( $f000==1 ){	next;}

		$j = 0;
		for($i=0;$i<$nFig;$i++){
			if( $_ eq $figLabel[$i] ){
				$j++;	next;
			}
		}
		for($i=0;$i<$nHyou;$i++){
			if( $_ eq $tblLabel[$i] ){
				$j++;	next;
			}
		}
		for($i=0;$i<$numEq;$i++){
			if( $_ eq $eqLabel[$i] ){
				$j++;	next;
			}
		}
		for($i=0;$i<$nItem;$i++){
			if( $_ eq $ptnItem[$i] ){
				$j++;	next;
			}
		}
		for($i=0;$i<$nBib;$i++){
			if( $_ eq $ptnBib[$i] ){
				$j++;	next;
			}
		}
		for($i=0;$i<$nSection;$i++){
			if( $_ eq $sectionLabel[$i] ){
				$j++;	next;
			}
		}

		if( $j>1 ){
			# 000723e $tmp000[$n000] = $_;	$n000++;
			# 000723e &print_warning('% txt2tex Error:'."ラベル ".$_." が".$j."重に定義されてます\n");
			$multiply_defined_label[$#multiply_defined_label+1] = $_;
			$n_multiply_defined_label[$#n_multiply_defined_label+1] = $j;
		}
	}
	close(LABEL);
}
#------------------------------------
#	式、図、表、箇条書きの参照ラベルを TeX に変換する(end)
#------------------------------------





#------------------------------------
#	参考文献をTeXに変換(begin)
#------------------------------------
#参考文献をTeXに変換
# ex:
#参考文献：
#apple1)文献１
#参4a)文献２
#
#参考文献の仕様：
#	1: /^参考文献：/の下に参考文献を書く
#	2: /^参照ラベル)文献名など/ のように参照ラベルと文献名などの間に ) を入れる

#	2a: 参照ラベルに（と）と(と)を書かない
#	3: ) がない行まで参考文献とみなす
#	4:箇条書きの中の式を処理できる．
#	5:参照するときは（参照ラベル）と書くとTeXで 1) となる。
#
#	980903

#初期設定

sub	initBib{
	$fBib = 0;		# 参考文献の行のとき(1),でないとき(0) 
	@ptnBib = //;	# 参考文献の参照ラベル(A1など）
	$nBib = 0;		# 参考文献の参照ラベルのインデックス

	$Bibname = ''; # bib defalut name
	$BibStyname = 'junsrt'; # bst defalut name
	@Bibtype = //; # Bib entry type
	@ptn_before = //;
	@ptn_after = //;
	@Bibwrite = //;
	$fBib_n = 0;
}

#参考文献をTeXに変換(begin)
sub	bib2tex{
	if( $fBib>=0 ){
		if( /^($H_LineNum)参考文献：[ 	　]*([^ 　	]+)：[ 	　]*([^ 　	]+)[ 	　]*\n$/ && ($fBib == 0 || $fBib == 2)){ # BibTeXを用いた参考文献の始まりの抽出 201001
			$fBib_n = 1;
			$Bibname = $2; $BibStyname = $3;
			$H_OUT="\n".$H_next."\\bibliography\{".$Bibname."\}\n".$H_next."\\bibliographystyle\{".$BibStyname."\}\n";	&print_OUT_euc;
			$_ = "";

			if( $fBib==2 ){		# 000219c
				$_ = $1;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):コマンド「参考文献：」が複数あります。文献番号がおかしくなります。'."\n");
				&insrt_matoato_warning($LineNum,"コマンド「参考文献：」が複数あります。文献番号がおかしくなります。");
				$_ = '';
			}
			$fBib=3;
		}elsif( /^($H_LineNum)参考文献：[ 	　]*$/o && ($fBib==0 || $fBib==2) ){	# 参考文献の始まりの抽出 000219c
			$H_OUT="\n".$H_next.'\begin{thebibliography}{99}'."\n";	&print_OUT_euc;	#000528c
			chop;	$_ = '';	# 参考文献：を削除

			if( $fBib==2 ){		# 000219c
				$_ = $1;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):コマンド「参考文献：」が複数あります。文献番号がおかしくなります。'."\n");
				&insrt_matoato_warning($LineNum,"コマンド「参考文献：」が複数あります。文献番号がおかしくなります。");
				$_ = '';
			}
			$fBib = 1;
		}elsif( /^($H_LineNum)参考文献：[ 	　]*([^ 　	]+)[ 	　]*\n$/ && ($fBib == 0 || $fBib == 2)){
			$fBib_n = 1;
			$Bibname = $2;
			&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):bstファイルが指定されていません。junsrt.bstを読み込みます。'."\n");
			&insrt_matoato_warning($LineNum,'bstファイルが指定されていません。junsrt.bstを読み込みます。');
			$H_OUT="\n".$H_next."\\bibliography\{".$Bibname."\}\n".$H_next."\\bibliographystyle\{".$BibStyname."\}\n";	&print_OUT_euc;
			$_ = "";

			if( $fBib==2 ){		# 000219c
				$_ = $1;
				&getLineNum;	&print_warning('% txt2tex Warning('.$LineNum.'):コマンド「参考文献：」が複数あります。文献番号がおかしくなります。'."\n");
				&insrt_matoato_warning($LineNum,"コマンド「参考文献：」が複数あります。文献番号がおかしくなります。");
				$_ = '';
			}
			$fBib=3;
		}elsif( $fBib==1 ){
			if( !(/[\)）]/) ){						# 参考文献の終わりの抽出
				$H_OUT=$H_next.'\end{thebibliography}'."\n";	&print_OUT_euc;
				#000219c $fBib = -1;
				$fBib = 2;	#000219c
			}
			if( $fBib == 1 ){						# 参考文献の中の抽出
				s/^[ 	　]*//;	# 参照ラベルの抽出
				$tmp_ = $_;
				s/^($H_LineNum)//;	# 981119f, 1/2
				chop;
				while( s/[\)）](.*)$// ){}
				$tmp = $_;
				s/ /　/g;					# 000213g
				$ptnBib[$nBib] = $_;
				$_ = $tmp_;
				# 981119f s/^$tmp[\)）]//;
				s/^($H_LineNum)$tmp\)/$1/;	#981119f, 2/2#110726b
				s/^($H_LineNum)$tmp）/$1/;	#981119f, 2/2#110726b

				#NG:Mac s/^$ptnBib[$nBib][\)）]//;
				$H_OUT=$H_next.'	\bibitem{'.$ptnBib[$nBib].'}'."\n";	&print_OUT_euc;
				$nBib++;
			}
		}elsif( $fBib == 3){
			if( !(/[\)）]/) ){						# 参考文献の終わりの抽出
				$fBib = 2;
			}
			if( $fBib == 3){
				s/^[ 	　]*//;
				$tmp_ = $_;
				s/^($H_LineNum)//;
				chop;
				s/^参：([^\)]+)\)//; # $1にLabel
				$ptnBib[$nBib] = $1;
				while(1){
					&txt2bib;
				}
				$nBib++;
			}
		}
	}
}

#------------------------------------
#	txtからbibへの書き込み
#------------------------------------
# txtで書かれた情報からbibへ変換し、bibに書き込む。
# bibのエントリとして
# 作成： -> author : 近大　太郎、近大　花子、Kindai Taro,Kennedy John Fitzgerald などのように姓 名の順で記載。姓と名の間は全角か半角のスペース、人物の区切りはカンマで記述
# 題名： -> title
# 雑誌： -> journal
# 巻数： -> volume
# 号数： -> number
# 頁数： -> pages
# 年：   -> year
# 出版： -> publisher
# 発表： -> presentation
# URL： -> url
# 参照： -> refdate
# を用意した(201001)。これらが含まれている情報から次のエントリタイプに分ける。
# @article author,title,journal,volume,number,pages,yearが必要。volumeが含まれたらこれに割り振られる。publisherが含まれても良い。
# @book author,title,publisher,yearが必要。publisherが含まれたらこれに割り振られる。
# @conferencearticle myjunsrt.bst,author,title,journal,presentation,yearが必要。presentationが含まれたらこれに含まれる。
# @myurl myjunsrt.bst,author,title,year,url,refdateが必要。urlが含まれたらこれに含める。
# @misc どれにも属さない場合。

sub txt2bib{
	if( /\t+巻数：.+\t/ || /\t+巻数：.+$/ || /\t+巻数：.+\n/){
		$Bibtype[$nBib] = "\@article";
	}elsif( /\t+出版：.+\t/ || /\t+出版：.+$/ || /\t+出版：.+\n/ && !(/\t+号数：.+\t/ || /\t+号数：.+$/ || /\t+号数：.+\n/)){
		$Bibtype[$nBib] = "\@book";
	}elsif( /\t+発表：.+\t/ || /\t+発表：.+$/ || /\t+発表：.+\n/){
		$Bibtype[$nBib] = "\@conferencearticle";
	}elsif( /\t+URL：\t/ || /\t+URL：$/ || /\t+URL：\n/){
		$Bibtype[$nBib] = "\@myurl";
	}elsif( !(/^\t/) ){
		$_ = $H_next . $_;
		&getLineNum;	&print_warning('% txt2tex Warning:参考文献の書き方が違います。'."\n");
		&insrt_matoato_warning($LineNum,"参考文献の書き方が違います。");
		last;
	}else{
		$Bibtype[$nBib] = "\@misc";
	}
	&conv_entry;
	last;
}

sub formatname{
	my ($ptnptn,$tmptmp);
	while( s/[,、]*([^,、]+?)[ 　]([^,、]+)[,、]*//){
		$ptn_before[$ptnptn] = $1;
		$ptn_after[$ptnptn] = $2;
		$ptnptn++;
	}

	for($i = 0; $i < $ptnptn; $i++){
		if($i == $ptnptn - 1){
			$tmptmp = $tmptmp . $ptn_before[$i] . ', ' . $ptn_after[$i];
		}else{
			$tmptmp = $tmptmp . $ptn_before[$i] . ', ' . $ptn_after[$i] . ' and ';
		}
	}

	return $tmptmp;
}
sub conv_entry{
	if( /\t+作成：([^\t]+)/ ){
		$tmp = $_;
		$_ = $1;
		$name = &formatname;
		$_ = $tmp;
		s/\t作成：([^\t]+)/\tauthor=\{$name\},/;
	}
	s/(\t)+題名：([^\t]+)/\ttitle=\{$2\},/;
	s/(\t)+雑誌：([^\t]+)/\tjournal=\{$2\},/;
	s/(\t)+巻数：([^\t]+)/\tvolume=\{$2\},/;
	s/(\t)+号数：([^\t]+)/\tnumber=\{$2\},/;
	s/(\t)+年：([^\t]+)/\tyear=\{$2\},/;
	s/(\t)+出版：([^\t]+)/\tpublisher=\{$2\},/;
	s/(\t)+頁数：([^\t]+)/\tpages=\{$2\},/;	
	s/(\t)+発表：([^\t]+)/\tpresentation=\{$2\},/;
	s/(\t)+URL：([^\t]+)/\turl=\{$2\},/;
	s/(\t)+参照：([^\t]+)/\trefdate=\{$2\},/;

	s/\t/\n\t/g;
	$Bibwrite[$nBib] = "\n" . $Bibtype[$nBib] . "\{" . $ptnBib[$nBib] . "," . $_ . "\n\}";
	$_ ='';
}

sub writeBib{
	if($fBib_n == 1){
		open(BIB,">>:utf8",$Bibname."\.bib");
		for($i=0;$i<$nBib;$i++){
			# print BIB encode("utf8",$Bibwrite[$i]."\n");
			print BIB $Bibwrite[$i]."\n";
		}
		close(BIB);
		
		open(OLD,"<:utf8",$H_INPUT_FILE);
		open(NEW,">:utf8","temp.tmp");
		while(<OLD>){
			if( /^参：(.+)\)\t(.+)\t(.+)/ ){}
			else{
				print NEW $_;
			}
		}
		close(OLD);
		close(NEW);
		system($H_MV." temp.tmp ".$H_INPUT_FILE);
	}
}
#参考文献をTeXに変換(end)


# 参考文献の参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelBib{
	print LABEL encode("utf8","	参考文献の参照ラベル一覧\n");
	for($i=0;$i<$nBib;$i++){
		print LABEL encode("utf8",$ptnBib[$i]."\n");
	}
}
# 参考文献の参照ラベルのファイルへの出力（あとで参照処理で使う）(end)

# 章，節，節節，付録番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(begin)
sub	writeLabelSection{
	print LABEL encode("utf8","	章，節，節節，付録番号の参照ラベル一覧\n");
	for($i=0;$i<$nSection;$i++){
		print LABEL encode("utf8",$sectionLabel[$i]."\n");
	}
}
# 章，節，節節，付録番号の参照ラベルのファイルへの出力（あとで参照処理で使う）(end)



#章，節，節節，付録のラベルを抽出，作成(begin) 980923
#注意： " を勝手に削除することにした
#	if( s/^(章|節|節節|付録)(：)(.*)$/$1$2$3\n$H_next \\label\{$3\}\n/ ){
#		$sectionLabel[$nSection] = $3;	$nSection++;
#	}
#章，節，節節，付録の書き方
#
#章：はじめに（ラベル）
#  参照は（ラベル）章と書くと1章となる

#	または
#章：はじめに
#  参照は（章：はじめに）章と書くと1章となる

# 980923
sub	get_label_section{
	my	($ptn, $tmp_, $tmp, $label);

	# ●（）の入れ子：中の（）を()に変換して対処, 000213e
	while( s/（([^）（]*)（([^（）]*)）/（$1\($2\)/ ){}	# （...（...） があったとき （...(...) にする


	# if( /^($H_LineNum)(章|節|節節|付録)：/ ){
	if( /^($H_LineNum)(章|節|節節|節節節|付録)：/ ){ # 211001
		s/^($H_LineNum)//;	$ptn = $1;
		chop;
		if( s/[ 	　]*（(.*)）[ 	　]*$// ){ 
			$tmp_ = $_;	$_ = $1;
		}else{
			$tmp_ = $_;
		}
		s/\"//g;	$label = &repl_label_moji($_);
		$_ = $tmp_."\n".$H_next.' \label{'.$label."\}\n";
		$sectionLabel[$nSection] = $label;	$nSection++;
		$_ = $ptn.$_;
	}

	#定理、補題、証明の書き方"
	#
	#定理：ラベル

	#	内容
	#定理終：
	#
	#参照は定理（定理：ラベル）と書くと定理1となる, 980924
	if( /^($H_LineNum)(定理|補題|証明)：/ ){
		chop;
		s/\"//g;
		$tmp_ = $_;	s/^($H_LineNum)//;
		$sectionLabel[$nSection] = &repl_label_moji($_);	$nSection++;
		# s/^(定理：.*)/$H_next\\newtheorem\{theorem\}\{定理\} \\label\{$1\}\n$H_next\\begin\{theorem\}\n/;	#981205"
		# s/^(補題：.*)/$H_next\\newtheorem\{lemma\}\{補題\} \\label\{$1\}\n$H_next\\begin\{lemma\}\n/;
		# s/^(証明：.*)/$H_next\\newtheorem\{proof\}\{証明\} \\label\{$1\}\n$H_next\\begin\{proof\}\n/;
		# s/^(定理：.*)/$H_next\\newtheorem\{theorem\}\{定理\}\n$H_next\\begin\{theorem\}\n$H_next \\label\{$1\}\n/;	#000213c
		# s/^(補題：.*)/$H_next\\newtheorem\{lemma\}\{補題\}\n$H_next\\begin\{lemma\}\n$H_next \\label\{$1\}\n/;
		# s/^(証明：.*)/$H_next\\newtheorem\{proof\}\{証明\}\n$H_next\\begin\{proof\}\n$H_next \\label\{$1\}\n/;
		# s/^(定理：.*)/$H_next\\begin\{theorem\}\n$H_next \\label\{$1\}\n/;	#000213c
		# s/^(補題：.*)/$H_next\\begin\{lemma\}\n$H_next \\label\{$1\}\n/;
		# s/^(証明：.*)/$H_next\\begin\{proof\}\n$H_next \\label\{$1\}\n/;
		if( s/^(定理：.*)/$H_next\\begin\{theorem\}\n$H_next \\label\{/ ){	$_=$_.&repl_label_moji($1)."\}\n"};	#000213c
		if( s/^(補題：.*)/$H_next\\begin\{lemma\}\n$H_next \\label\{/ ){	$_=$_.&repl_label_moji($1)."\}\n"};
		if( s/^(証明：.*)/$H_next\\begin\{proof\}\n$H_next \\label\{/ ){	$_=$_.&repl_label_moji($1)."\}\n"};
	}
	s/^($H_LineNum)定理終：/$H_next\\end\{theorem\}/;	#030825a
	s/^($H_LineNum)補題終：/$H_next\\end\{lemma\}/;	#030825a
	s/^($H_LineNum)証明終：/$H_next\\end\{proof\}/;	#030825a
}
#章，節，節節，付録のラベルを抽出，作成(end) 980923


#------------------------------------
#	参考文献をTeXに変換(end)
#------------------------------------



#------------------------------------
# C言語のコメント /* aaa */ を削除(begin)
#------------------------------------
#----- 初期設定　----
sub	initdelComment{
	$fdelComment = 0;	# /* */でコメント中のとき 1
}

sub delComment{		# #if 0  /******  のとき #endif まで読み飛ばす
	#  /* */でコメント中でないとき
	if( $fdelComment==0 ){
		# /* があるとき /*以降を削除（行の先頭に最も近い/*からコメント）
		while( /\/\*/ ){
			$new_ = '';
			$ptnOld = ''; # $ptn:現在の1文字、$ptnOld:１つ前の1文字

			while(s/^.//){
				$ptn = $&;
				if( $ptnOld eq '/' && $ptn eq '*' ){
					last;
				}
				$new_ = $new_.$ptnOld;
				$ptnOld = $ptn;
			}

			#  1行に /* と */ があるとき */以前を復帰（行の先頭に最も近い*/まで復帰）
			if( /\*\// ){
				$ptnOld = ''; # $ptn:現在の1文字、$ptnOld:１つ前の1文字

				while(s/^.//){
					$ptn = $&;
					if( $ptnOld eq '*' && $ptn eq '/' ){
						last;
					}
					$ptnOld = $ptn;
				}
				$_ = $new_.$_;
				$fdelComment = 0;
				chop;
				if( !(/[^ 	　]/) ){	next;}	# 981214a 1/2
				else{	$_ = $_."\n";}
			}else{
				$_ = $new_."\n";
				$fdelComment = 1;
			}
		}
	# /* */でコメント中のとき
	}else{
		#  */ があるとき */以前を削除（行の先頭に最も近い*/までコメント）
		if( /\*\// ){
			$ptnOld = ''; # $ptn:現在の1文字、$ptnOld:１つ前の1文字

			while(s/^.//){
				$ptn = $&;
				if( $ptnOld eq '*' && $ptn eq '/' ){
					last;
				}
				$ptnOld = $ptn;
			}
			$fdelComment = 0;
		# */ がないときすべて削除

		}else{
			$_ = '';
		}
	}
	if( !(/\n$/) ){	next;}	# 981214a 2/2
}
#------------------------------------
# C言語のコメント /* aaa */ を削除(end)
#------------------------------------



#------------------------------------
# C言語の #if 0 の内容を削除、#if 1, #else, #endif を削除

# ただし #if AAA, #ifdef は削除しない	(begin)
#------------------------------------

#	メインルーチンの書き方(delif0.pl)
#&init_del_if0;
#open(IN,"seisin.c);	open_OUT("seisin.out")
#while(<IN>){
#	# C言語の #if 0 の内容を削除、#if 1, #else, #endif を削除(print OUTを含む）
#	&del_if0;
#}
#close(IN);	&close_OUT;

sub	del_if0{	# C言語の #if 0 の内容を削除、#if 1, #else, #endif を削除

	# &del_if0_reigai;	# #if 0  /******  のとき #endif まで読み飛ばす
	&del_if0_if;		# #ifの処理
	&del_if0_else;		# #elseの処理
	&del_if0_endif;		# #endifの処理
	&del_if0_print;		# 出力条件判定

}

sub	init_del_if0{		#----- 初期設定　----
	$ireko = 0;
	$_if[$ireko] = 1;
	$reigai = 0;
}

sub del_if0_reigai{		# #if 0  /******  のとき #endif まで読み飛ばす
	if( /^\#if([	　 ]*)0([	　 ]*)\/\*\*\*\*/ ){
		$reigai = 1;
	}
	if( $reigai==1 ){
		$H_OUT=$_;	&print_OUT_euc;
		if( /^\#endif/ ){
			$reigai = 0;
		}
		next;
	}
}


sub del_if0_if{		# #ifの処理
	if( /^([	　 ]*)\#if/ ){
		$ireko += 1;
		if( /^([	　 ]*)\#if([	　 ]*)0/ ){
			$_if[$ireko] = 0;
		}elsif( /^([	　 ]*)\#if([	　 ]*)1/ ){
			$_if[$ireko] = 1;
		}else{
			$_if[$ireko] = 2;
			&del_if0_print;
		}
		next;
	}
}


sub del_if0_else{		# #elseの処理
	if( /^([	　 ]*)\#else/ ){
		if( $_if[$ireko] != 2 ){
			if( $_if[$ireko]==1 ){
				$_if[$ireko] = 0;
			}else{
				$_if[$ireko] = 1;
			}
		}else{
			&del_if0_print;
		}
		next;
	}
}


sub del_if0_endif{		# #endifの処理
	if( /^([	　 ]*)\#endif/ ){
		if( $_if[$ireko] == 2 ){
			&del_if0_print;
		}
		$ireko -= 1;
		next;
	}
}


sub del_if0_print{		# 出力処理
	$_print = 1;
	for($i=0;$i<=$ireko;$i++){
		$_print *= $_if[$i];
	}
	if( $_print>0 ){		# 出力処理
		# 行番号を行の先頭に書くsetLineNum, 980925(begin)
		# print OUT $.."Ｃ";
		#
		#if(1){
			# if( /^	/ && /\|／|＼/ ){	#行列のとき NG
			# s/(\|／|＼)([ 	　]*)/$1$2$.Ｃ/g;
			# }else{	#行列以外のとき
			# s/^([ 	　]*)/$1$.Ｃ/;
		# }
	# }else{
	s/^([ 	　]*)/$1$.Ｃ/;# if line off, comment 行番号作成
	# }
		# 行番号を行の先頭に書くsetLineNum, 980925(end)
		$H_OUT=$_;	&print_OUT_euc;
	}
}
#------------------------------------
# C言語の #if 0 の内容を削除、#if 1, #else, #endif を削除

# ただし #if AAA, #ifdef は削除しない	(end)
#------------------------------------




#------------------------------------
# C言語の#define文の処理(begin), 000506d, 000530a
# #define	DEBUG	1		 のとき、#if DEBUG で #if 0 の処理ができるようにする

# #define	kg/cm	"kg/cm"	 のとき、置換する

# #undef	kg/cm			 などのとき、以降の行の置換をやめる

#------------------------------------
sub	init_sharp_define{
	$H_eibun = 0;	# 1のとき英文モード
	$H_ignor = '"';	# ignorの記号の定義 "a", $H_eibun のときは $H_ignor =''; とする,000707i
	# $H_ignor = "'";	# ignorの記号の定義 "a", $H_eibun のときは $H_ignor =''; とする,000707i
	$H_f_write_theorem = 1;	# \newtheorem{theorem}{定理}と{補題}と{証明}を書くとき1, 020322e
	$H_repl_sharp_define_bef=//;
	$H_repl_sharp_define_aft=//;

	$H_sy_sharp_define = //;
}

sub	sharp_define_next{	# ^#defineのときnextする000506d
	if( /^($H_LineNum)\#(define|undef)[ 	]+/ ||
		/^\#(define|undef)[ 	]+/ ){	#000707g
		$H_OUT=$_;	&print_OUT_euc;
		next;
	}
}

sub	rm_sharp_define{	# ^#defineの行を削除000605a
	if( /^($H_LineNum)\#(define|undef)[ 	]+/ ){
		next;
	}
}

sub	sharp_define_eibun{	#000506e
	if( /^\#(define|undef)[ 	]+英文：/ ){
		if( $1 eq 'define' ){	$H_eibun=1;	$H_ignor='';}
		if( $1 eq 'undef' ){	$H_eibun=0;	$H_ignor='"';}
		next;
	}
}

sub	sharp_define_eibun_chk{	#000506e
	return $H_eibun;
}

sub	sharp_define{	#修正000605a
	my	($i, $f, $ptn1, $ptn2);

	if( /^\#define[ 	]+([^ 	\%]+)[ 	]+\'([^\']+)\'/ ){			#define A '\rm ' のとき030925
		$H_repl_sharp_define_bef[$#H_repl_sharp_define_bef+1] = $1;
		$H_repl_sharp_define_aft[$#H_repl_sharp_define_aft+1] = $2;
		$H_repl_sharp_define_aft[$#H_repl_sharp_define_aft] =~ s/\n//;
		next;
	}elsif( /^\#define[ 	]+([^ 	\%]+)[ 	]+([^ 	\%]+)/ ){			#define A B のとき
		$H_repl_sharp_define_bef[$#H_repl_sharp_define_bef+1] = $1;
		$H_repl_sharp_define_aft[$#H_repl_sharp_define_aft+1] = $2;
		$H_repl_sharp_define_aft[$#H_repl_sharp_define_aft] =~ s/\n//;
		next;
	}elsif( /^\#define[ 	]+([sy]\/.*)[ 	]*/ ){						#define s/..., #define	y/... のとき
		$ptn1 = $1;
		$ptn1 =~ s/\n//;
		$ptn1 =~ s/[^\\]\%.*//;
		$H_sy_sharp_define[$#H_sy_sharp_define+1] = $ptn1;
		next;
	}elsif( /^\#(define|undef)[ 	]+英文：/ ){					#define/#undef 英文： のとき
		$H_OUT=$_;	&print_OUT_euc;
		next;
	}elsif( /^#undef[ 	]+([sy]\/.*)[ 	]*/ ){						#undef s/..., #undef	y/...のとき
		$ptn1 = $1;
		$ptn1 =~ s/\n//;
		$ptn1 =~ s/[^\\]\%.*//;
		$f = 0;
		for( $i=0;$i<=$#H_sy_sharp_define;$i++ ){
			if( $H_sy_sharp_define[$i] eq $ptn1 ){	$H_sy_sharp_define[$i]='';	$f=1;}
		}
		if( $f==0 ){
			&print_warning('% txt2tex Warning('.$..'):無効な#undef文 '.$ptn1.' が書かれています。'."\n");
			&insrt_matoato_warning($LineNum,'無効な#undef文 '.$ptn1.' が書かれています。');
		}
		next;
	}elsif( /^#undef[ 	]+([^ 	\%]+)/ ){							#undef A のとき
		$ptn1 = $1;
		$f = 0;
		if( $ptn1 =~ /(定理|証明|補題)：/ ){#020322e
			$H_f_write_theorem = 0;
			$f = 1;
		}
		for( $i=0;$i<=$#H_repl_sharp_define_bef;$i++ ){
			if( $H_repl_sharp_define_bef[$i] eq $ptn1 ){	$H_repl_sharp_define_bef[$i]='';	$f=1;}
		}
		if( $f==0 ){
			&print_warning('% txt2tex Warning('.$..'):無効な#undef文 '.$ptn1.' が書かれています。'."\n");
			&insrt_matoato_warning($LineNum,'無効な#undef文 '.$ptn1.' が書かれています。');
		}
		next;
	}

	# for( $i=$#H_repl_sharp_define_bef;$i>=0;$i-- ){
	for( $i=0;$i<=$#H_repl_sharp_define_bef;$i++ ){
		if( length($H_repl_sharp_define_bef[$i])>0 ){
			s/$H_repl_sharp_define_bef[$i]/$H_repl_sharp_define_aft[$i]/g;
		}
	}
	# for( $i=$#H_sy_sharp_define;$i>=0;$i-- ){
	for( $i=0;$i<=$#H_sy_sharp_define;$i++ ){
		if( length($H_sy_sharp_define[$i])>0 ){
			eval $H_sy_sharp_define[$i];
		}
	}
}
#------------------------------------
# C言語の#define文の処理(end)
#------------------------------------

#------------------------------------
# まとあと警告文の削除(begin)
#------------------------------------
sub del_matoato_warning{
	$warning_count=0;
	open(OUT,'>:utf8','temp.tmp'); # とりあえずのファイル
	while(<IN>){
		if(!(/^\%\<\<\<([^\>]*)\>\>\>\%/)){
			print OUT $_;
		}
	}
	close(IN);
	close(OUT);
	if($H_OS eq "MSWin32"){
		open(TMP,$H_MV.' temp.tmp '.encode($H_JCODE2,$H_INPUT_FILE).'|'); # とりあえずのファイルを削除したいファイル名に変える
		close(TMP);
		open(IN,"<:utf8",encode($H_JCODE2,$H_INPUT_FILE));
	}elsif($H_OS eq "darwin"){
		open(TMP,$H_MV.' temp.tmp '.$H_INPUT_FILE.'|'); # とりあえずのファイルを削除したいファイル名に変える
		close(TMP);
		open(IN,"<:utf8",$H_INPUT_FILE);
	}
}
#------------------------------------
# まとあと警告文の削除(end)
#------------------------------------

#------------------------------------
# まとあと警告文の挿入(begin)
#------------------------------------
sub insrt_matoato_warning{
	if($H_OS eq "MSWin32"){
		$warning_sentence[$warning_count][0]='%<<< まとあとWARNING '.$_[1]." >>>%\n";
	}elsif($H_OS eq "darwin"){
		$warning_sentence[$warning_count][0]='%<<< まとあとWARNING '.$_[1]." >>>%\r\n";
	}
	$warning_sentence[$warning_count][1]=$_[0];
	$warning_count+=1;
}

sub insrt_matoato_warning_body{
	@warning = sort{ @$a[1] <=> @$b[1] } @warning_sentence;
	if($H_OS eq "MSWin32"){
		open(IN,"<:utf8",encode($H_JCODE2,$H_INPUT_FILE));
	}elsif($H_OS eq "darwin"){
		open(IN,"<:utf8",$H_INPUT_FILE);
	}
	open(OUT,'>:utf8','temp.tmp'); # とりあえずのファイル
	$i=0;
	while(<IN>){
		if($.==$warning[$i][1]){
			while($.==$warning[$i][1]){
				$i += 1;
				print OUT $warning[$i-1][0];
				if(!($warning[$i-1][1]==$warning[$i][1])){
					print OUT $_;
					next;
				}
			}
		}else{
			print OUT $_;
		}
		
	}
	close(IN);
	close(OUT);
	if($H_OS eq "MSWin32"){
		open(TMP,$H_MV.' temp.tmp '.encode($H_JCODE2,$H_INPUT_FILE).'|'); # とりあえずのファイルを削除したいファイル名に変える
	}elsif($H_OS eq "darwin"){
		open(TMP,$H_MV.' temp.tmp '.$H_INPUT_FILE.'|'); # とりあえずのファイルを削除したいファイル名に変える
	}
	close(TMP);
}
#------------------------------------
# まとあと警告文の挿入(end)
#------------------------------------

#1;

#************************************************************************
#************************************************************************
#end of matomato txt2tex.pl
#************************************************************************
#************************************************************************

1;
