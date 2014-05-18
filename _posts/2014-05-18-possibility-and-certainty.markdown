---
layout: post
title: find命令的时间格式
---

最近在熟悉数据的过程中，开始较多的使用<span id='edu'>find</span>命令,发现这确实是个文件查询的利器，再和<span id='edu'>xargs</span>或者<span id='edu'>exec</span>命令一起使用更是如虎添翼。

然后今天遇到一个关于find的<span id='edu'>时间格式</span>的小问题:<span id='edu'>到底find是怎么划分时间的</span>。

以常用的mtime为例，手册里面的介绍很简单：
<pre>
-mtime n
    File’s data was last modified n*24 hours ago.  See the comments for -atime to understand how rounding affects the interpretation of file modification times.
-atime n
    File  was  last accessed n*24 hours ago.  When find figures out how many 24-hour periods ago the file was last accessed, any fractional part is ignored, so to match -atime +1, a file has to have been accessed at least two days ago.
</pre>
恕我愚钝，看得似懂非懂的，而且记得是有正负号和不带符号的，这里什么都没说，略坑。然后看了几篇blog，发现一堆说法，也不知道哪个是对的，于是用手头的几个文件做了个实验。

环境
==========
<pre>
$ ll
-rw-r--r-- 1 pxu pxu 6.1K Apr 23 10:15 24-48.py
-rw-r--r-- 1 pxu pxu  14K Apr 22 06:53 48-72.py
-rw-rw-r-- 1 pxu pxu 5.5K Apr 21 11:53 72-96.py
-rwxr-xr-x 1 pxu pxu  11K Apr 21 02:42 72-96.py
$ date
Thu Apr 24 12:25:15 GMT 2014
</pre>
为了方便观察，我已经把文件的的名字修改为了修改距离现在的时间，比如24-48表示是距离现在24h以上48h以下修改的。

步骤
===========
下面就开始尝试吧：
<pre>
$ find . -type f -mtime -1
(null)
$ find . -type f -mtime 1
./24-48.py
$ find . -type f -mtime +1
./72-96.py
./48-72.py
./72-96.py
</pre>
似乎可以总结为:

+  -1表示距离现在24小时以内修改的文件
+  1 表示距离现在24小时到48小时内修改的文件
+  +1表示距离现在超过48小时内的所有文件

那么是不是这样呢，可以扩大区间继续实验：
<pre>
$ find . -type f -mtime -2
./24-48.py
$ find . -type f -mtime 2
./48-72.py
$ find . -type f -mtime +2
./72-96.py
./72-96.py
</pre>
确实，-2，2，+2分别表示48小时以内，48小时内72小时，72小时以上修改过的文件。

结论
==========
所以从数学的角度来说可以给出一个非常严谨的公式
<pre>
-n --> [ 0, 24 * n ) 
 n --> [ 24 * n, 24 * (n + 1))
+n --> [ 24 * (n + 1), + ∞ ）
</pre>

这个设计的<span id='edu'>完美之处</span>在于对于固定的n，正负号和不带符号的三种形式<span id='edu'>把从当前时刻到过去的整个时间段划分为了三部分</span>，顺序依次是<span id='edu'>负号、不带符号和正号</span>。
这个设计的<span id='edu'>坑爹之处</span>在于，当你使用<span id='edu'>mtime +1</span>的时候，会习惯性地<span id='edu'>错误的以为是24小时之前的</span>。如果不支持不带符号的参数，只有正负号来，就容易理解了，-1是24以内，+1是24小时以外。我猜测之所以支持不带符号的参数，主要是因为人们经常去取某一天修改的文件，虽然也可以同时用负号和正号来表示，比如：
<pre>
$ find . -type f -mtime 2
./48-72.py
$ find . -type f -mtime -3 -mtime +1
./48-72.py
</pre>
虽然这样很难理解，2居然是48小时到72小时，习惯中认为是第三天了，因为2在大家通常的意识是<span id='edu'>一个时间点，而不是一个时间段</span>。
