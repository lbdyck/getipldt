/* REXX - needed so this can run under a shell interface */
  /* --------------------  rexx procedure  -------------------- *
  | Name:      GETIPLDT                                        |
  |                                                            |
  | Function:  Using SDSF REXX query for all LPARs in the      |
  |            SYSPLEX for IPLINFO and extract the IPL         |
  |            date/time, and z/OS Release, and more to        |
  |            report.                                         |
  |                                                            |
  |            May also be run under OMVS shell.               |
  |                                                            |
  | Syntax:    %getipldt                                       |
  |                                                            |
  |            if a non-blank parm is provided then only the   |
  |            active/current system will be reported on.      |
  |                                                            |
  | Dependencies:  SDSF REXX                                   |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            2024/08/02 LBD - Right justify the msu's        |
  |            2024/08/01 LBD - Add CPU %                      |
  |            2024/05/28 LBD - Convert Julian date to         |
  |                             yyyy/mm/dd                     |
  |                           - if lpar is null then ----      |
  |            2024/05/25 LBD - redo using SDSF SYS info       |
  |            2024/02/10 LBD - enable use under shell         |
  |            2023/09/06 LBD - Add isfcalls(off)              |
  |            2022/11/28 LBD - Improve display                |
  |            2022/08/17 LBD - Creation                       |
  |                                                            |
  * ---------------------------------------------------------- *
  | Copyright (c) 2022-2024 by Lionel B. Dyck                  |
  | License is Copy-Left                                       |
  * ---------------------------------------------------------- */

  if Address() = 'SH' then 'clear'

  /* ----------------------- REXX --------------------------- *
  | Report on all systems in the sysplex using SDSF SYS info |
  |                                                          |
  | If parm is non blank then only display info on the       |
  | current system.                                          |
  * -------------------------------------------------------- */
  arg current

  isfsysname = '*'
  isfowner = "*"

  if current /= ''
  then do
    current = mvsvar('sysname')
    isffilter = 'sysname' current
  end

  /* -------------------------- *
  | Enable SDSF Rexx Interface |
  * -------------------------- */
  x = isfcalls('on')
  Address SDSF 'ISFEXEC sys'

  /* ------------- *
  | Report Header |
  * ------------- */
  say left('System',8) left('Level',13) ,
    left('IPL-Date',10) left('IPL-Time',8) ,
    left('IPLVol',6) ,
    left('LPAR',4) ,
    right('CPU%',6) ,
    left('CECmsu',6) left('SYSmsu',6) ,
    left('JESNode',8),
    left('CPU',6) 'Model' 'Serial'
  /* ------------------- *
  | Generate the report |
  * ------------------- */
  do i = 1 to sysname.0
    parse value cpc.i with processor'.'mdl'.'mfg'.'ver'.'serial
    parse value ipldate.i with date time
    parse value date with 3 year'.'days
    date = date('s',year||days,'j')
    date = left(date,4)'/'substr(date,5,2)'/'right(date,2)
    if strip(lpar.i) = '' then lpar.i = '----'
    say left(sysname.i,8) ,
      left(syslevel.i,13),
      date time ,
      left(iplvol.i,6) ,
      left(lpar.i,4) ,
      right(cpupr.i,6) ,
      right(msu.i,6) right(sysmsu.i,6) ,
      left(jesnode.i,8),
      left(processor,6) '  'mdl serial
  end
  x = isfcalls('off')
