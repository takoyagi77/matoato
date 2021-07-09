# matoato

まとあとはLaTeXの複雑なコマンドを簡単なコマンドで記述し、PDFへ変換を行います。[こちら][matoato]のプログラムを元に作成しております。

# Features

LaTeXで画像を挿入するためには以下のコマンドを記述する必要があります。

<details><summary>LaTeXでのコマンド</summary><div>

```LaTeX
\begin{figure}[ht]
	\centering
	\includegraphics[width=1.0\hsize]{写真ファイル.png} \\
	\caption{キャプション}
	\label{ラベル}}
\end{figure}
```
</div></details>

まとあとでは以下のコマンドで同じことが可能になります。

<details><summary>まとあとでのコマンド</summary><div>

```
	図：キャプション（写真ファイル.png,ラベル,1.0倍,ここ）
```
</div></details>

「図」の他にも「表」や「数式」などを見たまま書くだけでLaTeXのコマンドへ変換を行います。

# Requirement

* Perl 5系(5.12.4以上から動作確認)
* LaTeXを実行できる環境
* [VSCode](https://code.visualstudio.com)の利用を推奨

# How To Use

最も簡単な使い方は

```bash
perl matoato.pl --txt2tex Target.txt
```

これで「Target.txt」を「Target.tex」に変換します。

またPDFへ変換を行うには

```bash
perl matoato.pl --pdf Target.txt
```

これで「Target.txt」を「Target.pdf」に変換します。

その他の使い方は

```bash
perl matoato.pl -h
```

でヘルプを確認できます。またまとあとの基本的な書き方を見たい場合は

```bash
perl matoato.pl --help > readme.txt
perl matoato.pl --pdf readme.txt
```

を実行することで閲覧ができます。

# Update history

追加した機能などはファイルにPDFとしてまとめています。ぜひご覧ください。

# License

このプログラムは[権利者][matoato]の許可を得て改変しております。



[matoato]:https://www.vector.co.jp/soft/win95/writing/se296642.html