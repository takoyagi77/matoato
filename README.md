# matoato

まとあとはLaTeXの複雑なコマンドを簡単なコマンドで記述し、PDFへ変換を行います。[こちら](https://www.vector.co.jp/soft/win95/writing/se296642.html)のプログラムを元に作成しております。

# Features

<details><summary>LaTeXで画像を挿入するためには以下のコマンドを記述する必要があります。</summary><div>

```LaTeX
\begin{figure}[ht]
	\centering
	\includegraphics[width=1.0\hsize]{写真ファイル} \\
	\caption{キャプション}
	\label{ラベル}}
\end{figure}
```
</div></details>



# Requirement

* Perl 5系(5.12.3以上から動作確認)
* LaTeXを実行できる環境

# How To Use

最も簡単な使い方は

```bash
perl matoato.pl --txt2tex Target.txt
```

これで「Target.txt」を「Target.tex」に変換します。