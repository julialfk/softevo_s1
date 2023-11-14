module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Volume;
import Duplication;
import UnitSize;
import Complexity;

// projectLocation |project://smallsql0.21_src|
int main(loc projectLocation) {
    tuple[str rating, int lines] volume = countLinesProject(projectLocation);
    println("Total number of lines: <volume.lines>");
    println("Volume rating: <volume.rating>");
    str duplicates = countDuplicates(projectLocation, volume.lines);
    println("Duplication rating: <duplicates>");
    str UnitSize = mainUnitSize(projectLocation);
    println("UnitSize: <UnitSize>");
    str complexity = mainComplexity(projectLocation);
    println("complexity: <complexity>");
    return 0;
}
