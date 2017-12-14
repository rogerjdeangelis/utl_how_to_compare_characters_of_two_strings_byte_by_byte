How to compare characters of two strings, byte by byte;

 Two solutions

    1. WPS/PROC R or IML/R
    2. SAS

see
https://goo.gl/fwkqfN
https://stackoverflow.com/questions/47821084/how-to-compare-characters-of-two-string-at-each-index


INPUT
=====
                                       |     RULES
 SD1.HAVE total obs=1                  |
                                       |     abcde234
    Obs    STRING1     STRING2         |     abcd1224
                                       |
     1     abcde234    abcd1224        |     11110111   * 1 means equal

PROCESS
=======

 1. SAS (all the code - although WPS supports peeks, pokes and addr the syntax is a little different?)

    data want;
      length zroOne $8;
      set sd1.have;
      array stra[8] $1 _temporary_;
      array strb[8] $1 _temporary_;
      call pokelong(put(string1,$char8.),addrlong(stra[1]),8,1);
      call pokelong(put(string2,$char8.),addrlong(strb[1]),8,1);
      do i=1 to 8;
         zroOne=cats(zroOne,put((stra[i]=strb[i]),1.));
      end;
      put zroOne;
    run;quit;

 2. WPS/PROC R or IML/R  working code (left out interface with SAS)

     str1 <- str_split(string1, "")[[1]];
     str2 <- str_split(string2, "")[[1]];
     want<- str1==str2;

OUTPUT
======

  WORK.WANT total obs=1

     Obs     ZROONE

      1     11110101

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
 data sd1.have;
   string1 = "abcde234";
   string2 = "abcd1224";
 run;quit;

*                      __
__      ___ __  ___   / / __  _ __ ___   ___   _ __
\ \ /\ / / '_ \/ __| / / '_ \| '__/ _ \ / __| | '__|
 \ V  V /| |_) \__ \/ /| |_) | | | (_) | (__  | |
  \_/\_/ | .__/|___/_/ | .__/|_|  \___/ \___| |_|
         |_|           |_|
;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
library(stringr);
have<-read_sas("d:/sd1/have.sas7bdat");
have;
string1 <- "abcd_234";
string2 <- "abcd1224";
str1 <- str_split(string1, "")[[1]];
str2 <- str_split(string2, "")[[1]];
want<- t(as.data.frame(str1==str2));
want;
endsubmit;
import r=want data=wrk.wantwps;
run;quit;
');

data want;
  set wantwps;
  zroOne=cats(of v:);
  put zroOne;
  keep zroOne;
run;quit;

proc print data=want;
run;quit;

*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

data want;
  length zroOne $8;
  set sd1.have;
  array stra[8] $1 _temporary_;
  array strb[8] $1 _temporary_;
  call pokelong(put(string1,$char8.),addrlong(stra[1]),8,1);
  call pokelong(put(string2,$char8.),addrlong(strb[1]),8,1);
  do i=1 to 8;
     zroOne=cats(zroOne,put((stra[i]=strb[i]),1.));
  end;
  put zroOne;
run;quit;

