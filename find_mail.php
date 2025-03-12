#!/usr/bin/php
<?php
#处理qmail的mail.info日志文件, 根据发件人，显示发件过程
$user=$_SERVER['argv'][1];
if ($_SERVER['argv'][2]!='' and file_exists($_SERVER['argv'][2])) {
    $f=$_SERVER['argv'][2];
} else {
    $f="/debian6/var/log/mail.info";
    if (!file_exists($f)) {
        $f="/var/log/mail.info";
    }
}
if ($user=='') {
    die($_SERVER['argv'][0]." liushiwei@mydomain.com\r\n");
}
$fp=fopen($f, "r");
while ($line=fgets($fp)) {
    $b=explode('qmail: ', $line);
    $b=explode(' ', $b[1]);
/*
(
    [0] => 1489859148.562482
    [1] => new
    [2] => msg
    [3] => 406805

)
*/
    switch ($b[1]) {
        case 'info':
            if ($b[6]=="from" and $b[7]=="<$user>") {
                $aid=substr($b[3], 0, -1);
                unset($count[$aid]);
                $count[$aid]['ok']=$line;
            }
            break;
        case 'starting':
            if ($b[2]=='delivery' and $b[6]=='to') {
                $aid=$b[5];
                if ($count[$aid]['ok']=='') {
                    break;
                }
                $rid=substr($b[3], 0, -1);
                $count[$aid][$rid]++;
                $m[$rid].=$line;
                $r[$rid]=$aid;
            }
            break;
        case 'delivery':
            $rid=substr($b[2], 0, -1);
            $aid=$r[$rid];
            unset($r[$rid]);
            if ($aid=='') {
                break;
            }
            if ($count[$aid][$rid]>0) {
                $count[$aid][$rid]++;
                $m[$rid].=$line;
            }
            break;
        case 'end':
            if ($b[2]=='msg') {
                $aid=trim($b[3]);
                if (empty($count) or count($count)<2) {
                    break;
                }
                if ($count[$aid]['ok']=='') {
                    break;
                }
                $msg=$count[$aid]['ok'];
                unset($count[$aid]['ok']);
                while ($c=each($count[$aid])) {
                    $rid=$c['key'];
                    $msg.=$m[$rid];
                    $msg.="------\n";
                    unset($m[$rid]);
                    echo "rid=$rid,";
                }
                $msg.=$line;
                echo $msg;
                echo "\r\n********************************\r\n";
                unset($count[$aid]);
            }
            break;
    }
}
