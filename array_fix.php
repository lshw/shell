#!/usr/bin/php
<?php
/*
 *早期的php代码，在数组的key中，会忽略单引号，比如用 $_SERVER[REMOTE_ADDR];
 *这会造成歧义， REMOTE_ADDR是个字符串还是和宏定义
 *在PHP7中对此会发出警告，说下一个版本的php会对此直接报错
 *这个程序会对php源代码作出自动修改，比如更正成$_SERVER['REMOTE_ADDR']
 *方法原理是， 在找到每一个可能需要修正的地方，就对修正后的代码， 用php -l 进行测试，出错就放弃此次修正
*/

$f=$_SERVER['argv'][1];
if (!file_exists($f)) {
    die("文件没有找到 $f\r\n");
}
$all=file($f);
$t=0;
$o='';
$change = '';
$skip = 0; //跳过注释
$lines=count($all);
for ($i0=0; $i0<$lines; $i0++) {
    $a=$all[$i0];
    if (substr(trim($a), 0, 2)=='//') {
        if ($skip == 1) {//找 注释结束标志
            $b=strpos($a, "/*");
        } else { //找注释开始标志
            $b=strpos($a, "*/");
        }
        if ($b!==false) {//继续处理剩余行
            $o.=substr($a, 0, $b);
            $a=substr($a, $b);
        } else {//处理下一行
            $o.=$a;
            continue;
        }
    }
    $bef='';
    for ($i=0; $i<strlen($a); $i++) {
        $c=$a[$i];
        if ($skip == 1) {//注释中
            $o.=$c;
            if ($bef == '*' and $c=='/') {
                $skip = 0;
            }
            $bef = $c;
            continue;
        }
        switch ($t) {
            case 0: //先找'['
                if ($bef == '/' and $c == '/') { //后面的不做处理
                    $o .= substr($a, $i, strlen($a));
                    $i=strlen($a);
                    break;
                }
                if ($bef == '/' and $c == '*') { //开始注释
                    $skip = 1;
                    $o.=$c;
                    $bef = $c;
                    break;
                }
                $o.=$c;
                if ($c=='[') {
                    //向前找$
                    for ($i2 = $i-1; $i2 >= 0; $i2--) {
                        if ($a[$i2]=='$') {
                            $t=1; //找到有效的数组
                            $al=0; //数组key长度
                            $begin=$i+1;
                        } elseif (!is_vname($a[$i2])) {
                            break; //非有效数组名称， 跳过
                        }
                    }
                }
                $bef = $c;
                break;
            case 1: //找']'
                if ($c==']') {
                    $d=substr($a, $begin, $i-$begin);
                    if ($d=='' or is_numeric($d)) { //数组的key是数字，跳过不处理
                        $o.=$d.$c;
                    } else {
                        file_put_contents("/tmp/$f.tmp", $o."'$d'".substr($a, $i));
                        for ($i1=$i0+1; $i1<$lines; $i1++) {
                            file_put_contents("/tmp/$f.tmp", $all[$i1], FILE_APPEND); //剩余行
                        }
                        $err=0;
                        system("php -l /tmp/$f.tmp >/dev/null 2>/dev/null", $err);
                        unlink("/tmp/$f.tmp");
                        if ($err==0) { //php测试不出错， 增加单引号
                            $o.="'$d'$c";
                            $change=1;
                        } else {  //php测试出错， 当前的数组，可能在字符串中， 则不做处理
                            $o.="$d$c";
                        }
                    }
                    $t=0;
                    $bef = $c;
                    break;
                } elseif (is_vname($c)
                and  ! ($c >= '0' and $c <= '9' and $al == 0)) { /*不能数字作为开始*/
                    $bef = $c;
                    $al++; //数组key长度
                    break;
                } else {
                    $o.=substr($a, $begin, $i-$begin).$c; //非有效变量名， 跳过当次处理， 继续寻找'['
                    $t=0;
                    $bef = $c;
                    break;
                }
        }
        $bef = $c;
    }
}
if ($change == 1) {
    file_put_contents($f, $o);
}
function is_vname($c)
{
                return $c == '_'
                or ($c >= 'a' and $c <='z')
                or ($c >= 'A' and $c <= 'Z')
                or ($c >= chr(0x80) and $c <= chr(0xff));
}
