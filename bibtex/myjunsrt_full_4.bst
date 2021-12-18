	% version 0.30 for JBibTeX versions 0.30 or later, LaTeX version 2.09.
	% Copyright (C) 1990, all rights reserved.
	%
	% This file is derived from btxbst.doc of BibTeX 0.99c
	%
	% Copying of this file is authorized only if either
	% (1) you make absolutely no changes to your copy, including name, or
	% (2) if you do make changes, you name it something other than
	% jbtxbst.doc, jplain.bst, junsrt.bst, jalpha.bst, jabbrv.bst,
	% tipsj.bst, jipsj.bst, tieice.bst, jname.bst, jorsj.bst
	%
	% This restriction helps ensure that all standard styles are identical.
	% The file jbtxbst.doc has the documentation for this style.
	%
	% Please notify Shouichi MATSUI(matsui@denken.or.jp) of any bugs in
	% these standard styles or in this documentation file.
	% 松井 正一  (財) 電力中央研究所　情報システム部

	% -------------------------------------------------------------------------------------------------------
	% 小坂研用参考文献スタイルファイル myjunsrt.bst
	% 		作成：ななみん 2020年10月
	%		履歴：2020年12月 3日　「year」の前のコンマを削除
	%			 2020年12月19日　色々変更
	%			 2021年10月13日　「number」がない場合「year」の後にコンマがない問題を修正 ver.4
	%
	% junsrt.bstを基にいろいろ解読、変更した。基本はjunsrtです。
	% 何を変更したかは、kosakalab.bibの最初を参考にしてください。
	%
	% このファイルを触る方へ。
	% 		bstファイルはTeX言語(not equal LaTeX)を使ってるものと思います。
	% 		TeX言語がPascal言語を基に作られた(ってWikipediaに書いてあった気がする)ので基本はPascalを参考に。
	% 		但し、Pascalで調べてもよく分からなかったので、下の方にあるURLを見るといいかも？
	% 		またこのファイルに僕が解読した部分についてはコメントで書いてるので参考にしてください。
	% 		さらにbibに「@TESTTYPE」を作って、FUNCTION{TESTTYPE}を変更、makeすると任意の挙動を確認できると思います。
	% 		特にこの言語、if$がややこしいです。是非活用してください。
	% -------------------------------------------------------------------------------------------------------


	% ーーーーーーーーーーーーーーーーーーー自分用メモーーーーーーーーーーーーーーーーーーー
	% bstは参考文献の書式設定用ファイル。Pascal言語を使っているらしい。
	% 変数の種類
	%	グローバル変数	：文献とは無関係に用意される変数。宣言すると文献の数に関わらず1つだけ用意される。
	%	エントリ変数	：文献ごとに用意される変数。bstファイル内で値を代入、使用できる。
	%	フィールド変数	：文献ごとに用意される変数。bibファイルから抽出した情報を格納。
	% 文字列定数は「"」で囲う。 ex. "Hello"
	% 整数定数は「#」の後に数値を書く。 ex. #1
	% 変数、関数の命名に大文字小文字の区別はしないらしい。
	% スタックの仕組み
	%	labelという変数に"Hello "が格納されているとする。
	%	label "A" * 'label :=
	%	上記式を実行すると、labelには"Hello A"が格納される。
	%	「label」で変数labelの中身を呼び出しスタックに代入、"A"をスタックに代入、「*」でスタック内で文字を連結。「'label」をスタックに入れ、「:=」でスタックをプッシュして代入。
	%	「label」：変数の中身。「'label」：変数名label。
	% bstファイルのコマンド
	%	ENTRY
	%		エントリ変数やフィールド変数の宣言に用いる。引数は3つ
	%			第一引数：使用するフィールド変数名。ここで宣言した名前のデータをbibファイルから抽出してフィールド変数に格納される。
	%			第二引数：使用する整数型のエントリ変数名。空でも良い。
	%			第三引数：使用する文字列型のエントリ変数名。空でも良い。
	%		このほかにcrossref,sort.key$という文字列型エントリ変数が用意される。
	%	INTEGERS
	%		整数型の変数を宣言する。引数は1つで、変数名を羅列する。
	%		文字列型変数が格納できる最大文字数を格納するentry.max$(エントリ変数用)とglobal.max$(グローバル変数用)が宣言される。
	%	STRINGS
	%		INTEGERSの文字列版。引数1つ。
	%	MACRO
	%		文字列に置き換えるマクロを定義。引数は2つ。
	%			第一引数：マクロ名
	%			第二引数：置き換えられる文字列(「"」で囲う)
	%		ここで定義したマクロはbibファイルでも使用可能。
	%	FUNCTION
	%		関数を定義するコマンド。引数は2つ。
	%			第一引数：関数名
	%			第二引数：関数として定義する処理の羅列
	%	上記5つは変数や関数を定義
	%	READ
	%		bibファイルから引用された文献についてデータを抽出してENTRYで宣言したフィールド変数に代入。値がない場合はmissingとされる。引数なし。
	%	これはbibファイルからデータを読み込む用
	%	EXECUTE
	%		関数を実行するコマンド。引数1つでFUNCTIONで宣言した名を入力。
	%	ITERATE
	%		引用されている文献ごとに1つの関数を実行。EXECUTEと同様に関数名1つを記述。
	%	REVERSE
	%		ITERATEと同じ。但し逆の順序で実行。
	%	SORT
	%		sort.key$が辞書順になるように文献を並び替える。
	%	上記4つは出力に対する処理用
	%	呼び出す順番に制約があり、
	%		ENTRYとREADは必ず1回ずつ。多くても少なくてもだめ。
	%		ENTRYと全てのMACRO、エントリタイプと同じ名前の関数、default.type関数を定義するFUNCTIONは、READより前に呼び出す。エントリタイプ：articleやbookなどのbibファイルで@の後につけるやつ
	%		READはEXECUTE,ITERATE,REVERSE,SORTより前に呼び出す。
	%		変数や関数は使用される関数より前にコマンドで宣言する必要がある。
	% sort.key$等あらかじめ用意された変数(ビルドイン変数)のようにビルドイン関数が存在し、ビルドイン変数と同様に最後に「$」がつく。以下ビルドイン関数の説明。
	%	>				整数型を想定。引数としてスタックから2つポップ。1つ目の引数が2つ目の引数より大きい場合1、小さい場合0をスタックにプッシュ。
	%	<				「>」の逆。
	%	=				整数型、文字列型を想定。スタックからポップしてきた物が同一なら1を、そうでなければ0をスタックにプッシュ。
	%	+				整数型を想定。スタックから2つポップしてきて和をスタックにプッシュ。
	%	-				整数型を想定。1番目にスタックからポップしてきた整数から2番目にスタックからポップしてきた整数の差をスタックにプッシュ。
	%	*				文字列型を想定。1番目にスタックからポップしてきた文字列に2番目にスタックからポップしてきた文字列を連結してスタックにプッシュ。
	%	:=				スタックを2つポップ。変数名を初めにポップし、次に変数の値をポップし、代入。スタックへのプッシュはなし。
	%	add.period$		文字列型を想定。スタックから1つポップ。「}」以外の最後の文字が「.?!」以外の場合、「.」を追加し、スタックにプッシュ。
	%	call.type$		現在処理している文献のエントリタイプと同じ名前の関数を実行。未知の場合default.type関数を実行。
	%	change.case$	文字列型を想定。スタックから2つポップ。1番目にポップした文字により2番目にポップした文字列を変換し、スタックにプッシュ。
	%						「t」か「T」：文字列内の最初の文字、「:」や「 」の後に続く文字、以外を全て小文字に変換。
	%						「l」か「L」：文字列内の全ての文字を小文字に変換。
	%						「u」か「U」：文字列内の全ての文字を大文字に変換。
	%						これら以外の文字：警告を表示し、そのまま2番目の文字列をスタックへプッシュ。
	%	chr.to.int$		1文字の文字列型を想定。ポップされた文字列に対応するASCIIコード数値へ変換し、スタックへプッシュ。
	%	cite$			現在処理している文献のラベルをスタックにプッシュ。
	%	duplicate$		スタックから1つポップし、2つプッシュする。(複製)
	%	empty$			スタックから1つポップ、それがmissingのフィールド変数、スペースだけの文字列のとき1、それ以外の時0をスタックにプッシュ。
	%	format.name$	スタックから3つポップ、1つ目は名前のフォーマット文字列({ff}等)、2つ目は整数、3つ目はandで繋がれた人物名の文字列がポップ。
	%					整数番目の人物を3つ目から取り出し、1つ目のフォーマットにしたがって整形し、スタックにプッシュ。
	%	if$				スタックから3つポップ、1つ目2つ目が処理の内容、3つ目が整数を想定。3つ目が0より大きければ2つ目を、そうでなければ1つ目を処理する。
	%					ex. flagA{処理1}{処理2}if$		flagAが0より大きい場合処理1を、そうでない場合処理2を実行する。
	%	int.to.chr$		chr.to.int$の逆。
	%	int.to.str$		整数を文字列に変換し、スタックにプッシュ。
	%	missing$		empty$のmissingのみ版
	%	newline$		出力バッファが空のとき空行をbblファイルに書き込み
	%	num.names$		スタックから1つポップ、文字列(人物名のリスト)を想定。ポップされた文字列の前後がスペースのandの数+1(人物の数)をスタックにプッシュ。
	%	pop$			スタックから1つポップ。不要な物を取り除く時に使用
	%	preamble$		bibファイル内に含まれるPREAMBLEで定義した文字列を全て連結し、スタックにプッシュ。
	%	purify$			スタックから1つポップ、文字列を想定。文字列からスペース、ハイフン、\を取り除き、スタックへプッシュ。
	%	quote$			スタックに「"」をプッシュ。
	%	skip$			何の処理もしない関数
	%	stack$			スタックの中身を全てポップ
	%	substring$		スタックから3つポップ、2つ整数がポップされ最後に文字列がポップされることが想定。文字列に対して2つ目にポップした整数番目から1つ目にポップした整数分文字を取り出しスタックにプッシュ。
	%	swap$			スタックから2つポップし、逆の順番でスタックへプッシュ。
	%	text.length$	スタックから1つポップ、文字列を想定。文字数をスタックへプッシュ。\alphaなどを1文字、{}はカウントしない。
	%	text.prefix$	スタックから2つポップ、1つ目は整数、2つ目は文字列を想定。整数分文字列の最初から取り出しスタックへプッシュ。substring$と違い、\alphaなどの特殊文字は1つ、{}はカウントしない。
	%	top$			スタックから1つポップ、ターミナルやログに表示。デバッグ用
	%	type$			現在処理している文献のエントリタイプの文字列をスタックにプッシュ。
	%	warning$		スタックから1つポップ、警告メッセージを表示した後に、ポップした物を表示。警告カウントを増加。
	%	while$			スタックから2つポップ、処理が2つポップされることを想定。2つ目にポップした処理を実行後、0より大きいなら1つ目にポップした処理を繰り返す。
	%	width$			スタックから1つポップ、文字列を想定。文字列を出力した際の幅を整数としてスタックへプッシュ。
	%	write$			スタックから1つポップ、文字列を想定。bblファイルに出力。
	%
	%
	%
	% 変更するといい関数
	%	output.nonnull
	%	format.names
	%	FUNCTIONで独自のENTRYを持つやつを作る
	%
	%
	%
	% Bibliography
	%	https://qiita.com/HexagramNM/items/7c59f307e55010caf693
	%	https://www.okomeda.net/wp/506/
	%	https://ja.wikipedia.org/wiki/BibTeX
	% ーーーーーーーーーーーーーーーーーーー自分用メモーーーーーーーーーーーーーーーーーーー



ENTRY
  { address
    author
    booktitle
    chapter
    edition
    editor
    howpublished
    institution
    journal
    key
    month
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    volume
    year
    yomi
	presentation % 講演番号用、conferencearticleで使用
	url % URL用、myurlで使用
	refdate % URLを参照した日付、myurlで使用
	sitename % URLのサイト名
	additionaldata % URLの参照日に追加する情報
  }
  {is.kanji.entry} % 整数型

  { label } % 文字列型


INTEGERS { output.state before.all mid.sentence after.sentence after.block } % 整数型

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}
FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}
FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}
FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=

}
STRINGS { s t } % 文字列型

FUNCTION {mywirte}{ write$ newline$ }


FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =

    { ", " * write$ }

    { output.state after.block =
	{ 

          %add.period$ write$
		  ", " * write$ % ENTRY毎の区切り文字の指定

	  newline$
	  "\newblock " write$
	}

	{ output.state before.all =
	    'write$

	    { add.period$ " " * write$ }

	  if$
	}

      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}
FUNCTION {output.nonnull.noncomma}
{ 's :=
  output.state mid.sentence =

    { " " * write$ }

    { output.state after.block =
	{ 

          %add.period$ write$
		  " " * write$ % ENTRY毎の区切り文字の指定

	  newline$
	  "\newblock " write$
	}

	{ output.state before.all =
	    'write$

	    { add.period$ " " * write$ }

	  if$
	}

      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}
FUNCTION {output.nonnull.author.period}
{ s is.kanji.str$
	{ ". " * write$ }
	{ write$ }
	if$
	newline$
	"\newblock " write$
}
FUNCTION {output.nonnull.period}
{
	". " * write$
	newline$
	"\newblock " write$
}
FUNCTION {output.comma}
{
	", " * write$
	newline$
	"\newblock " write$
}
FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}
FUNCTION {output.noncomma}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull.noncomma
  if$
}
FUNCTION {output.author.period}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull.author.period
  if$
}
FUNCTION {output.publisher}
{ volume empty$
	'output.noncomma
	'output.check
  if$
}
FUNCTION {output.period}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull.period
  if$
}
FUNCTION {output} % volumeがemptyの場合コンマなしで出力するように変更
{ duplicate$ empty$
	'pop$
	{ volume empty$
		'output.nonnull.noncomma
		'output.nonnull
	if$
	}
  if$
}
FUNCTION {output.bibitem}
{ newline$

  "\bibitem{" write$

  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}
FUNCTION {fin.entry}
{ 

  add.period$

  write$
  newline$
}
FUNCTION {new.block}
{ output.state before.all =

    'skip$
    { after.block 'output.state := }

  if$
}
FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
	'skip$
	{ after.sentence 'output.state := }
      if$
    }
  if$
}
FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}
FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}
FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}
FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}


FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { duplicate$ is.kanji.str$
	'skip$
	{ "{\em " swap$ * "}" * }
      if$
    }
  if$
}

INTEGERS { nameptr namesleft numnames }
FUNCTION {format.names}
{
	's := % Sは処理する内容のやつ
	#1 'nameptr := % nameptrは処理する名前の整数 ex. Abc and Def and Ghi -> nameptr=1 : Abc , nameptr=2 : Def , nameptr=3 : Ghi
	s num.names$ 'numnames := % numnamesは人数
	numnames 'namesleft := % namesleftも人数、処理する残り人数かな？
	numnames #0 <
		{ % 人数が3人以上の場合
			s nameptr "{ff}{ll}" format.name$ is.kanji.str$
				{s nameptr "{ll}" format.name$ 't :=} % 苗字のみ記載 ex. 近大太郎 -> 近大
				{s nameptr "{f.~}{v.~}{ll}{, jj}" format.name$ 't :=}
			if$
			t
			s is.kanji.str$
				{ "他" * }
				{ " et al." * }
			if$
		}

		{ % 人数が3人未満の場合
			{ namesleft #0 > } % whileの条件式
			{ s nameptr "{ff}{ll}" format.name$ is.kanji.str$ % whileの実行式		fotmat.name$ : {ff}{ll}に従ってauthorを一人づつ整列  is.kanji.str$ : スタックから1つポップ、それが全角文字(?)なら1をそれ以外なら0をスタックにプッシュ
				%{s nameptr "{ff}{ll}" format.name$ 't :=} % default
				{s nameptr "{ll }{ff}" format.name$ 't :=} % 姓名
				%{s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=} % default
				{s nameptr "{f.~}{v.~}{ll}{, jj}" format.name$ 't :=} % 名前を省略系、苗字を全て記載 ex. Kindai Taro -> T. Kindai
				% この時点ではtは処理した人
			if$

				nameptr #1 > % nameptrが2以上の時
					{ namesleft #1 >
						{ ", " * t * } % namesleftが2以上の時、直前の人物に「, 」を追加、この時点でtは次の人になっているぽい
						{ t "others" = % namesleftが2未満の時
							{ s is.kanji.str$ % 次の人がothersの時
								{"ほか" * } % 一人でも日本人が含まれる場合、「ほか」で「ほか」と出力されるぽい。なぜ？？？
								{", et~al." * } % 全員外人の場合
							if$
							}
							{ s is.kanji.str$ % 次の人がothersでない時
								{", " * t * } % 一人でも日本人が含まれる場合
								{ numnames #2 = % 全員外人の場合
									{" and " * t * } % 人数が2人の場合
									{", and " * t * } % 人数が3人以上の場合
								if$
								}
							if$
							}
						if$
						}
					if$
					}
					't % nameptrが1以下の場合、「'tをスタックにプッシュする」という処理を行う
				if$
				nameptr #1 + 'nameptr := % nameptrを+1
				namesleft #1 - 'namesleft := % namesleftを-1
			}
			while$
		}
	if$
}
FUNCTION {format.authors}
{ author empty$
    { "" }

    { author format.names }

  if$
}
FUNCTION {format.editors}
{ editor empty$
    { "" }

    { editor format.names

      editor num.names$ #1 >
 	{ editor is.kanji.str$

 		{"（編）" * } {", editors" * } if$

 	}
 	{ editor is.kanji.str$

 		{"（編）" *} {", editor" * } if$

 	}
      if$
    }
  if$
}

FUNCTION {format.title}

{ title empty$

    { "" }


    %{ title "t" change.case$ }
    { title } % そのまま出力したいことの方が多いはずだから消した


  if$
}
FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
	{ t #1 #2 substring$ "--" = not
	    { "--" *
	      t #2 global.max$ substring$ 't :=
	    }
	    {   { t #1 #1 substring$ "-" = }
		{ "-" *
		  t #2 global.max$ substring$ 't :=
		}
	      while$
	    }
	  if$
	}
	{ t #1 #1 substring$ *
	  t #2 global.max$ substring$ 't :=
	}
      if$
    }
  while$
}
FUNCTION {format.date}
{ year empty$
    { month empty$
	{ "" }
	{ "there's a month but no year in " cite$ * warning$
	  month
	}
      if$
    }
    { month empty$
	%'year
	{ "(" year ")" * * } % yearを「()」で囲む
	{ month " " * year * }
      if$
    }
  if$
}

FUNCTION {format.btitle}

{ title emphasize
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}
FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}
FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { volume is.kanji.str$
	{ volume }
	{ is.kanji.entry
	    {"第" volume * "巻" *}
	    {"Vol." volume tie.or.space.connect}
	  if$
	}
      if$
      series empty$
	'skip$
	{ series is.kanji.str$
	    { volume empty$
		{series swap$ * }

		{series ", " * swap$ * }

	      if$
	    }
	    { " of " * series emphasize * }
	  if$
	}
      if$
      "volume and number" number either.or.check
    }
  if$
}
FUNCTION {format.number.series}
{ volume empty$
    { number empty$
	{ series field.or.null }
	{ number is.kanji.str$ 
	    { number }
	    {"No." number tie.or.space.connect}
	  if$
	  series empty$
	    { "there's a number but no series in " cite$ * warning$ }
	    { series is.kanji.str$

	        { series ", " * swap$ * }

	        { " in " * series * }
	      if$
	    }
	  if$
	}
      if$
    }
    { "" }
  if$
}
FUNCTION {format.edition}
{ edition empty$
    { "" }
    { edition is.kanji.str$
	{ edition }
        { is.kanji.entry
	    {"第" edition * "版" *}
	    { output.state mid.sentence =
	      { edition "l" change.case$ " edition" * }
	      { edition "t" change.case$ " edition" * }
              if$
	    }
	  if$
        }
      if$
    }
  if$
}
INTEGERS { multiresult }
FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
	{ #1 'multiresult := }
	{ t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}
FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check

 	{ "pp." pages n.dashify tie.or.space.connect }
	{ "p." pages tie.or.space.connect }

      if$
    }
  if$
}


FUNCTION {format.vol.num.pages}
{ volume empty$
     {""}


     { volume is.kanji.str$
        {volume  ", " * }
        {"Vol." volume tie.or.space.connect ", " * }
        %{"vol." volume tie.or.space.connect ", " * }
       if$
     }


  if$
  number empty$
    'skip$

    { number is.kanji.str$
        {number *}
        {"No." number tie.or.space.connect *}
        %{"no." number tie.or.space.connect *}
      if$

      volume empty$
	{ "there's a number but no volume in " cite$ * warning$ }
	'skip$
      if$
    }
  if$

  year empty$
	'skip$
	%{ number empty$
	%	{duplicate$ pop$ " " * format.date ", " * *}
		{duplicate$ pop$ " " * format.date *}
	%  if$
	%}
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
	{ pop$ format.pages }
	{ number empty$

 	    { year empty$ 
			{ format.pages * }
			{ ", " * format.pages * }
			if$
		}
			%{ format.pages * }
			%{ ", " * format.pages * }
		{ ", " * format.pages * }

	  if$
	}
      if$
    }
  if$
}

FUNCTION {format.url} {"available from\url{<" url ">}" * *}
FUNCTION {format.reference.date} {"(参照日 " refdate ")" * *}


FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
	{ chapter is.kanji.str$
	    { "" }
	    { is.kanji.entry
		{"章"}
		{"chapter"}
	      if$
	    }
	  if$
	}
	{ type "l" change.case$ }
      if$
      chapter is.kanji.str$ not is.kanji.entry and
          {"第" chapter * swap$ *}
          { chapter is.kanji.str$
		{chapter *}
		{chapter tie.or.space.connect}
	    if$
	  }
      if$
      pages empty$
	'skip$

	{ ", " * format.pages * }

      if$
    }
  if$
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { editor empty$
 	{ booktitle is.kanji.str$
 	    { " " booktitle emphasize * }

 	    { "In " booktitle emphasize * }

 	  if$
 	}
 	{ booktitle is.kanji.str$

 	    { " " format.editors * ", " * booktitle * }


 	    { "In " format.editors * ", " * booktitle emphasize * }

 	  if$
 	}
      if$
    }
  if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and



    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}
FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}
FUNCTION {format.tr.number}
{ type empty$
    { "Technical Report" }
    'type
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
}
FUNCTION {format.article.crossref}
{ key empty$
    { journal empty$
	{ "need key or journal for " cite$ * " to crossref " * crossref *
	  warning$
	  ""
	}
 	{ title is.kanji.str$
 	    { " " journal *  }

  	    { "In {\em " journal * "\/}" * }

          if$
	}
      if$
    }
    { title is.kanji.str$
 	{ " " key * }

  	{ "In " key * }

      if$
    }
  if$
  " \cite{" * crossref * "}" *
}
FUNCTION {format.crossref.editor}
{ editor is.kanji.str$

     {editor #1 "{ff}" format.name$ duplicate$

      empty$
 	{pop$ editor #1 "{ll}" format.name$}
 	'skip$
      if$
      }

      {editor #1 "{vv~}{ll}" format.name$}

  if$
  editor num.names$ duplicate$
  #2 >
    { editor is.kanji.str$

	  {pop$ "ほか" *} {pop$ ", et~al." * } if$

    }
    { #2 <
	'skip$

	{ editor #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =

 	    { editor is.kanji.str$

 		{"ほか" *} {", et~al." * } if$

 	    }
 	    { editor is.kanji.str$
 		{

		  ", " *

 		   editor #2 "{ff}" format.name$ duplicate$
 		   empty$
 			{pop$ editor #2 "{ll}" format.name$}
 			'skip$
 		   if$
 		 *
 		}
 		{" and " * editor #2 "{vv~}{ll}" format.name$ * }
 	      if$
 	    }
	  if$
	}
      if$
    }
  if$
}
FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
       title is.kanji.str$

 	{"  "} {"In "} if$

    }
    { volume is.kanji.str$
	{ volume }
	{ is.kanji.entry
	    {"第" volume * "巻" *}
	    {"Vol." volume tie.or.space.connect " of " *  }
	  if$
	}
      if$
    }
  if$
  editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ series empty$
	    { "need editor, key, or series for " cite$ * " to crossref " *
	      crossref * warning$
	      "" *
	    }

	    { series is.kanji.str$

		{ series ", " * swap$ * }

	        { "{\em " * series * "\/}" * }
	      if$
	    }

	  if$
	}
	{ key * }
      if$
    }
    { format.crossref.editor * }
  if$
  " \cite{" * crossref * "}" *
}
FUNCTION {format.incoll.inproc.crossref}
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ booktitle empty$
	    { "need editor, key, or booktitle for " cite$ * " to crossref " *
	      crossref * warning$
	      ""
	    }
 	    { booktitle is.kanji.str$
 		{ booktitle }

 		{"In {\em " booktitle * "\/}" * }

 	       if$
 	    }
	  if$
	}

	{ "In " key * }

      if$
    }
    { title is.kanji.str$
 	{" " format.crossref.editor * }

 	{"In " format.crossref.editor * }

      if$
    }
  if$
  " \cite{" * crossref * "}" *
}
FUNCTION {article}
{ output.bibitem
  format.authors "author" output.check
  %format.authors "author" output.author.period
  new.block
  format.title "title" output.check
  %format.title "title" output.period
  new.block
  crossref missing$
    %{ journal emphasize "journal" output.check
    { journal "journal" output.check % 強調はいらない？

	  %format.date "year" output.check
      format.vol.num.pages output % "year"をformat.vol.num.pagesに組み込んだ
      %format.date "year" output.check
	  %format.date "year" output.noncomma

	}
    { format.article.crossref output.nonnull
      format.pages output
    }
  if$

  new.block
  note output
  fin.entry
}

FUNCTION {book}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
	  %format.authors "author" output.author.period
      crossref missing$
	{ "author and editor" editor either.or.check }
	'skip$
      if$
    }
  if$
  new.block
  format.btitle "title" output.check
  %format.btitle "title" output.period
  crossref missing$
    { format.bvolume output
      new.block
      format.number.series output

      new.sentence

      publisher "publisher" output.check
      address output
    }
    { new.block
      format.book.crossref output.nonnull
    }
  if$
  format.edition output

  %format.date "year" output.check
  format.date "year" output.noncomma
  format.pages "pages" output.check

  new.block
  note output
  fin.entry
}
FUNCTION {booklet}
{ output.bibitem
  format.authors output
  new.block
  format.title "title" output.check
  howpublished address new.block.checkb
  howpublished output
  address output
  format.date output

  new.block
  note output
  fin.entry
}
FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
	{ "author and editor" editor either.or.check }
	'skip$
      if$
    }
  if$
  new.block
  format.btitle "title" output.check
  crossref missing$
    { format.bvolume output

      format.chapter.pages "chapter and pages" output.check

      new.block
      format.number.series output

      new.sentence

      publisher "publisher" output.check
      address output
    }

    { format.chapter.pages "chapter and pages" output.check

      new.block
      format.book.crossref output.nonnull
    }
  if$
  format.edition output
  format.date "year" output.check


  new.block
  note output
  fin.entry
}
FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output


      format.chapter.pages output



      new.sentence

      publisher "publisher" output.check
      address output
      format.edition output

      format.date "year" output.check

    }
    { format.incoll.inproc.crossref output.nonnull
      format.chapter.pages output
    }
  if$

  new.block
  note output
  fin.entry
}
FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output


      format.pages output



      address empty$
	{ organization publisher new.sentence.checkb

	  organization output

	  publisher output

	  format.date "year" output.check

	}
	{ address output.nonnull

	  format.date "year" output.check


	  new.sentence

	  organization output

	  publisher output

	}
      if$
    }
    { format.incoll.inproc.crossref output.nonnull
      format.pages output
    }
  if$

  new.block
  note output
  fin.entry
}
FUNCTION {conference} { inproceedings }
FUNCTION {manual}
{ output.bibitem
  author empty$
    { organization empty$
	'skip$
	{ organization output.nonnull
	  address output
	}
      if$
    }
    { format.authors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
	{ address new.block.checka
	  address output
	}
	'skip$
      if$
    }
    { organization address new.block.checkb
      organization output
      address output
    }
  if$
  format.edition output
  format.date output

  new.block
  note output
  fin.entry
}
FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check

  new.block
  note output
  fin.entry
}
FUNCTION {misc}
{ output.bibitem
  format.authors output
  title howpublished new.block.checkb
  format.title output
  howpublished new.block.checka
  howpublished output
  format.date output

  new.block
  note output
  fin.entry
  empty.misc.check
}
FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.btitle "title" output.check
  new.block
  "PhD thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check

  new.block
  note output
  fin.entry
}
FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { organization output }
    { format.editors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  format.bvolume output
  format.number.series output
  address empty$
    { editor empty$
	{ publisher new.sentence.checka }
	{ organization publisher new.sentence.checkb
	  organization output
	}
      if$
      publisher output
      format.date "year" output.check

    }
    { address output.nonnull
      format.date "year" output.check


      new.sentence

      editor empty$
	'skip$
	{ organization output }
      if$
      publisher output
    }
  if$
  new.block
  note output
  fin.entry
}
FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  format.tr.number output.nonnull
  institution "institution" output.check
  address output
  format.date "year" output.check

  new.block
  note output
  fin.entry
}
FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  note "note" output.check
  format.date output
  fin.entry
}
FUNCTION {conferencearticle}
{
	output.bibitem
	format.authors "author" output.check
	new.block
	format.title "title" output.check
	new.block
	journal "journal" output.check
	%format.date "year" output.check
	format.vol.num.pages output
	presentation "presentation" output.check
	%format.date "year" output.noncomma
	fin.entry
}
FUNCTION {myurl}
{
	output.bibitem
	format.authors "author" output.check
	format.title "title" output.check
	format.date
	additionaldata empty$ { "" * }{ ", " additionaldata " " * * swap$ * }if$ "year" output.noncomma
	sitename "sitename" output.check
	format.url "url" output.check
	format.reference.date "refdate" output.check
	fin.entry
}
INTEGERS {test.x test.y}
STRINGS {test.a test.b}
FUNCTION {TESTTYPE} % bstの挙動確認用
{
	newline$
	"---------------------------------------" write$ newline$
	#3 'test.x :=
	test.x #2 > % 人数が3人以上の場合
		{ s nameptr "{ff}{ll}" format.name$ is.kanji.str$
			{s nameptr "{ll}" format.name$ 't :=}
			{s nameptr "{f.~}{v.~}{ll}{, jj}" format.name$ 't :=}
		if$
		't
		{ s is.kanji.str$
			{" $B$[$+ (B" * }
			{" et al." * }
		if$
		}
		}



	newline$
	"---------------------------------------" write$ newline$
}
FUNCTION {default.type} { misc }

MACRO {jan} {"January"}
MACRO {feb} {"February"}
MACRO {mar} {"March"}
MACRO {apr} {"April"}
MACRO {may} {"May"}
MACRO {jun} {"June"}
MACRO {jul} {"July"}
MACRO {aug} {"August"}
MACRO {sep} {"September"}
MACRO {oct} {"October"}
MACRO {nov} {"November"}
MACRO {dec} {"December"}


MACRO {acmcs} {"ACM Computing Surveys"}
MACRO {acta} {"Acta Informatica"}
MACRO {cacm} {"Communications of the ACM"}
MACRO {ibmjrd} {"IBM Journal of Research and Development"}
MACRO {ibmsj} {"IBM Systems Journal"}
MACRO {ieeese} {"IEEE Transactions on Software Engineering"}
MACRO {ieeetc} {"IEEE Transactions on Computers"}
MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}
MACRO {ipl} {"Information Processing Letters"}
MACRO {jacm} {"Journal of the ACM"}
MACRO {jcss} {"Journal of Computer and System Sciences"}
MACRO {scp} {"Science of Computer Programming"}
MACRO {sicomp} {"SIAM Journal on Computing"}
MACRO {tocs} {"ACM Transactions on Computer Systems"}
MACRO {tods} {"ACM Transactions on Database Systems"}
MACRO {tog} {"ACM Transactions on Graphics"}
MACRO {toms} {"ACM Transactions on Mathematical Software"}
MACRO {toois} {"ACM Transactions on Office Information Systems"}
MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}
MACRO {tcs} {"Theoretical Computer Science"}
MACRO {tieice} {"電子情報通信学会論文誌"}
MACRO {tipsj}  {"情報処理学会論文誌"}
MACRO {jipsj}  {"Journal of Informatin Processing Society of Japan"}
MACRO {jorsj}  {"Journal of the Operations Research Society of Japan"}

READ
FUNCTION {set.is.kanji.entry}
{
  author    field.or.null is.kanji.str$
  title     field.or.null is.kanji.str$ or
  editor    field.or.null is.kanji.str$ or
  journal   field.or.null is.kanji.str$ or
  booktitle field.or.null is.kanji.str$ or
  series    field.or.null is.kanji.str$ or
  'is.kanji.entry :=
}
ITERATE {set.is.kanji.entry}






STRINGS { longest.label }
INTEGERS { number.label longest.label.width }
FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'number.label :=
  #0 'longest.label.width :=
}
FUNCTION {longest.label.pass}
{ number.label int.to.str$ 'label :=
  number.label #1 + 'number.label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}
EXECUTE {initialize.longest.label}
ITERATE {longest.label.pass}

FUNCTION {begin.bib}

{ preamble$ empty$

    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{"  longest.label  * "}" * write$ newline$
}
EXECUTE {begin.bib}
EXECUTE {init.state.consts}
ITERATE {call.type$}
FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}
EXECUTE {end.bib}
