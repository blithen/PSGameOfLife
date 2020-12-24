function Draw($Go,$GridSize){
    $PrintStr = "`n" * 10 + "~" * ([int]$GridSize+[int]$GridSize+1)
    $PrintStr = $PrintStr + "`n"
    foreach ($row in $Go){
        $line = ""
        foreach ($col in $row){
            $line += "|$col"
        }
        $PrintStr += $line + "|`n"
    }
    $PrintStr = $PrintStr + "~" * ([int]$GridSize+[int]$GridSize)
    write-output $PrintStr
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
            $LiveCount = foreach ($item in $SurrondingCells){
                if ($item -eq "O"){$item}
            }

            #$LiveCount = $SurrondingCells | % -parallel { if ($_ -eq "O"){$_} }
            

            if ($Go[$i][$x] -eq "O" -and ($LiveCount.count -eq 2 -or $LiveCount.count -eq 3)){
                $Changes[$i][$x] = "O"
            }
            elseif ($Go[$i][$x] -eq " " -and  $LiveCount.count -eq 3) {
                $Changes[$i][$x] = "O"
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
2. Randomize each cell
3. Set each cell randomly leaning towards alive
4. Set each cell randomly leaning towards dead
5. Load a grid from a file
"@

if ($GridInitialSetOptions -notmatch '[12345]'){
    $GridInitialSetOptions = 2
}

$GridSize = read-host -Prompt "Please enter the number you want to be squared for the grid size, with a maximum of 75 (Default is 25)"

if ($GridSize -notmatch "[^A-z]"){
    $GridSize = 25
}
elseif ([int]$GridSize -gt 83){
    $GridSize = 83
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
                    $GridObj[$i][$x] = "O"
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
                    $GridObj[$i][$x] = "O"
                }
                else{
                    if (((get-random -Minimum 0 -Maximum 100)%2 -eq 0)){
                        $GridObj[$i][$x] = "O"
                    }
                    else
                    {
                        $GridObj[$i][$x] = " "
                    }
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
                        $GridObj[$i][$x] = "O"
                    }
                    else
                    {
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
    return
}
$run = 0
while ($true){
    if ($run -eq 0){
        Draw $GridObj $GridSize
        writefile $GridObj $GridSize 
        start-sleep 3
    }
    else
    {
        Draw $GridObj $GridSize
    }

    $GridObj = Check -Go $GridObj -GridSize $GridSize
    start-sleep 0.025
    #write-host "$run"
    $run++
}