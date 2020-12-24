function Draw($Go,$GridSize){
    $ESC = [char]27
    $ENDChar = $ESC + "[0m"
    $PrintStr = "$ESC[93m~$EndChar" * ([int]$GridSize+[int]$GridSize+1)
    $PrintStr = $PrintStr + "`n"
    foreach ($row in $Go){
        $line = ""
        foreach ($col in $row){
            if ($col -eq "O"){
                $line += "|$ESC[92m$col$EndChar"
            }
            elseif ($col -eq "X"){
                $line += "|$ESC[91m$col$EndChar"
            }
            elseif ($col -eq "L"){
                $line += "|$ESC[96m$col$EndChar"
            }
            else{
                $line += "| "
            }
            
        }
        $PrintStr += "$line|`n"
    }
    $PrintStr = $PrintStr + "$ESC[93m~$EndChar" * ([int]$GridSize+[int]$GridSize+1) 
    return $PrintStr
}

function writefile($Go,$GridSize){
    $PrintStr = ""
    foreach ($row in $Go){
        $line = ""
        foreach ($col in $row){
            $line += "|$col"
        }
        $PrintStr += $line + "|`n"
    }
    $printstr | Out-File -FilePath ".\Run_$([math]::Round(((get-date) - (get-date -Date "1970/01/01")).TotalSeconds)).txt"
}

function check ($Go,$GridSize) {
    $Changes = @(0..([int]$GridSize-1))

    for ($i = 0; $i -lt $GridSize; $i++){
        $Changes[$i] = @(0..($GridSize-1))
    }

    for ($i = 0; $i -lt $Go.count; $i++){

        for ($x = 0; $x -lt $Go[$i].Count; $x++){

            if ($i-1 -lt 0 -and $x-1 -lt 0){
                $SurrondingCells = "INV","INV","INV",$Go[$i+1][$x+1],$Go[$i+1][$x],$Go[$i][$x+1],"INV","INV"
            }
            elseif ($i+1 -gt $Go.count -and $x+1 -gt $Go.count){
                $SurrondingCells = $Go[$i-1][$x-1],$Go[$i-1][$x],$Go[$i][$x-1],"INV","INV","INV","INV","INV"
            }
            elseif ($i-1 -lt 0){
                $SurrondingCells = "INV","INV",$Go[$i][$x-1],$Go[$i+1][$x+1],$Go[$i+1][$x],$Go[$i][$x+1],"INV",$Go[$i+1][$x-1]
            }
            elseif ($i+1 -gt $Go.count-1){
                $SurrondingCells = $Go[$i-1][$x-1],$Go[$i-1][$x],$Go[$i][$x-1],"INV","INV",$Go[$i][$x+1],$Go[$i-1][$x+1],"INV"
            }
            elseif ($x-1 -lt 0){
                $SurrondingCells = "INV",$Go[$i-1][$x],"INV",$Go[$i+1][$x+1],$Go[$i+1][$x],$Go[$i][$x+1],$Go[$i-1][$x+1],"INV"
            }
            elseif ($x+1 -gt $Go.count){
                $SurrondingCells = $Go[$i-1][$x-1],$Go[$i-1][$x],$Go[$i][$x-1],"INV",$Go[$i+1][$x],"INV","INV",$Go[$i+1][$x-1]
            }
            else{
                $SurrondingCells = $Go[$i-1][$x-1],$Go[$i-1][$x],$Go[$i][$x-1],$Go[$i+1][$x+1],$Go[$i+1][$x],$Go[$i][$x+1],$Go[$i-1][$x+1],$Go[$i+1][$x-1]
            }
            #fastest way the filter... surprisingly
            $LiveCount = foreach ($item in $SurrondingCells){if ($item -match "O|X|L"){$item}}
            $FirstType = foreach ($item in $LiveCount){if ($item -eq "O"){$item}}
            $SecondType = foreach ($item in $LiveCount){if ($item -eq "X"){$item}}
            $ThirdType = foreach ($item in $LiveCount){if ($item -eq "L"){$item}}

            if ($Go[$i][$x] -match "O|X" -and ($LiveCount.count -eq 2 -or $LiveCount.count -eq 3)){
                if ((get-random -min 1 -max 100) -eq 4){
                    $Changes[$i][$x] = "L"
                }
                else{
                    $Changes[$i][$x] = $Go[$i][$x]
                }
            }
            elseif ($Go[$i][$x] -eq " " -and  $LiveCount.count -eq 3) {
                if ($ThirdType.Count -gt 0){$Changes[$i][$x] = "L"}
                elseif ($FirstType.Count -gt $SecondType.Count){
                    $Changes[$i][$x] = "O"
                }elseif ($SecondType.Count -gt $FirstType.Count){
                    $Changes[$i][$x] = "X"
                }
            }
            else
            {
                $Changes[$i][$x] = " "
            }
        }
    }

    return $Changes
}

$GridInitialSetOptions = read-host -Prompt @"
How would you like to set the initial board?
1. Board fully alive
2. Randomize each cell with O and X
3. Randomize each cell with O
4. Randomize each cell with X
5. Load a grid from a file
6. Infect Mode
"@

if ($GridInitialSetOptions -notmatch '[123456]'){
    $GridInitialSetOptions = 2
}

$GridSize = read-host -Prompt "Please enter the number you want to be squared for the grid size, with a maximum of 55 (Default is 55)"

if ($GridSize -notmatch "[^A-z]"){
    $GridSize = 55
}

if ($GridInitialSetOptions -eq 6){
    if ($gridsize -gt 40){
        $GridSize = 40
    }
}

$GridObj = @(0..([int]$GridSize-1))

for ($i = 0; $i -lt $GridSize; $i++){
    $GridObj[$i] = @(0..($GridSize-1))
}

switch ($GridInitialSetOptions) {
    1 {  
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                $GridObj[$i][$x] = "O"
            }
        }
    }
    2 {  
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                    if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                        if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                            $GridObj[$i][$x] = "O"
                        }
                        else{
                            $GridObj[$i][$x] = " "
                        }
                    }
                    else{
                        if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                            $GridObj[$i][$x] = "X"
                        }
                        else{
                            $GridObj[$i][$x] = " "
                        }
                    }
                }
                else{
                    $GridObj[$i][$x] = " "
                }
            }
        }
    }
    3 {
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                    if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                        $GridObj[$i][$x] = "O"
                    }
                    else{
                        $GridObj[$i][$x] = " "
                    }
                }
                else{
                    $GridObj[$i][$x] = " "
                }
            }
        }
    }
    4 {
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                    if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                        $GridObj[$i][$x] = "X"
                    }
                    else{
                        $GridObj[$i][$x] = " "
                    }
                }
                else{
                    $GridObj[$i][$x] = " "
                }
            }
        }
    }
    5 {
        $FilePath = read-host "Input the grid file path: "
        $InitalGrid = get-content $FilePath
        $InitalGrid = $InitalGrid -replace "^\||\|$"
        $InitalGrid = $InitalGrid -replace "[\n\r][\n\r]"
        for ($i = 0; $i -lt $InitalGrid.count; $i++){
            $line = $InitalGrid[$i]
            $split = $line -split "\|"
            #not sure why i need to plus one, but otherwise this skipped everything.
            if ($split.count+1 -lt $InitalGrid.count){
                continue
            }
            for ($x = 0; $x -lt $split.count; $x++){
                $GridObj[$i][$x] = $split[$x]
            }
        }
    }
    6 {
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                    if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                        $GridObj[$i][$x] = "O"
                    }
                    else{
                        $GridObj[$i][$x] = "X"
                    }
                }
                else{
                    $GridObj[$i][$x] = " "
                }
            }
        }
        $Infect = $true
    }
    Default {
        for ($i = 0; $i -lt $GridObj.count; $i++){
            $line = $GridObj[$i]
            for ($x = 0; $x -lt $line.count; $x++){
                if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                    $GridObj[$i][$x] = "O"
                }
                else{
                    $GridObj[$i][$x] = " "
                }
            }
        }
    }
}

$run = 0
$out = Draw $GridObj $GridSize
$pshost = get-host
$pswindow = $pshost.ui.RawUI

$newsize = $pswindow.WindowSize
$newsize.height = [int]$GridSize+3
$newsize.width = 200
try{
    $pswindow.WindowSize = $newsize
}
catch
{
    
}
$out = Draw $GridObj $GridSize
writefile $GridObj $GridSize 
write-host $out
start-sleep 3
measure-command {
    while ($true){
        write-host $out
        $out = Draw $GridObj $GridSize
        $GridObj = Check -Go $GridObj -GridSize $GridSize
        start-sleep 0.025
        $run++
        if ($host.ui.RawUi.KeyAvailable){
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
            #81 is Q
            if (($key.VirtualKeyCode -eq 81)){
                break
            }
        }
    }
}