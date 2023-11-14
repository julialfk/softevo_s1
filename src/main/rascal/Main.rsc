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
    int lines = countLinesProject(projectLines);
    println("lines: <lines>");
    real duplicates = countDuplicates(projectLines, lines);
    println("duplicate percentage: <duplicates * 100>");
    // str UnitSize = mainUnitSize(fileLocations, lines);
    // println("UnitSize: <UnitSize>");
    tuple[str CC, str US] CCUS = mainComplexity(fileLocations, lines);
    println("complexity: <CCUS.CC>");
    println("unitsize: <CCUS.US>");
    return lines;
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}
