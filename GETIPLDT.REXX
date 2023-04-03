  /* --------------------  rexx procedure  -------------------- *
  | Name:      GETIPLDT                                        |
  |                                                            |
  | Function:  Using SDSF REXX query for all LPARs in the      |
  |            SYSPLEX for IPLINFO and extract the IPL         |
  |            date/time, and z/OS Release.                    |
  |                                                            |
  | Syntax:    %getipldt                                       |
  |                                                            |
  | Dependencies:  SDSF REXX                                   |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            2022/11/28 LBD - Improve display                |
  |            2022/08/17 LBD - Creation                       |
  |                                                            |
  * ---------------------------------------------------------- */

  /* -------------------- *
  | Define key variables |
  * -------------------- */
  parse value '' with null hit system. lpar
  lparc = 0

  /* ----------------------- *
  | Issue the query command |
  * ----------------------- */
  x = isfcalls('on')
  cmd.0 = 1
  cmd.1 = 'RO *ALL,D IPLINFO'
  Address SDSF "ISFSLASH ("cmd.") (WAIT)"
  do i = 1 to isfulog.0
    if hit = null then do
      if pos('IEE254I',isfulog.i) > 0 then do
         hit = 1
         lparc = lparc +1
         lpar = mvsvar('sysname')
         end
      if pos('IEE421I',isfulog.i) = 0 then iterate
      hit = 1
      iterate
    end
    if word(isfulog.i,2) = 'RESPONSES' then do
      lpar = word(isfulog.i,1)
      lparc = lparc + 1
    end
    if lpar = null then iterate
    if word(isfulog.i,1) = 'SYSTEM' then
      system.lparc = lpar word(isfulog.i,6) word(isfulog.i,4)
    if word(isfulog.i,1) = 'RELEASE' then
      system.lparc = system.lparc word(isfulog.i,6) word(isfulog.i,3)
  end
  system.0 = lparc

  Say 'SYSPLEX  IPL Date/Time       Release'
  say '-------  ------------------- -------------'
  do i = 1 to lparc
    say left(word(system.i,1),8) subword(system.i,2)
  end
