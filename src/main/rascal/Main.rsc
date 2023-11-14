module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;
import Volume;
import Duplication;
import ComplexityUnits;

// projectLocation main(|project://smallsql0.21_src|)
int main(loc projectLocation) {
    list[loc] fileLocations = getFiles(projectLocation);
    list[list[str]] projectLines = getProjectLines(projectLocation);

    tuple[str rating, int lines] volume = countLinesProject(projectLines);
    println("Total number of lines: <volume.lines>");
    println("Volume rating: <volume.rating>");
    
    str duplicates = countDuplicates(projectLines, volume.lines);
    println("Duplication rating: <duplicates>");
    
    tuple[str CC, str US] CCUS = mainComplexity(fileLocations, volume.lines);
    println("complexity: <CCUS.CC>");
    println("unitsize: <CCUS.US>");
    
    return 0;
}
