#!/usr/bin/env bash
declare -A STATUS
STATUS[0]="new"                     #Added to repo, no code yet
STATUS[1]="in-progress"             #Code imported from website and/or in work locally
STATUS[2]="solved"                  #Problem done, no more code change. Readme/comments may still be edited
STATUS[3]="abandoned"               #Problem cannot be resolved by myself. WIP, comment and readme as explanation may be available.
STATUS[4]="solved-and-upgrading"    #Problem in the process of being upgraded from the previous repo directory management (XXXX. ___) to problems/ and readme to complete.