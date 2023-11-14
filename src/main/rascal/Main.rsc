module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Volume;
import Duplication;

int main(loc projectLocation) {
    int lines = countLinesProject(projectLocation);
    println("lines: <lines>");
    real duplicates = countDuplicates(projectLocation, lines);
    println("duplicate percentage: <duplicates * 100>");
    return 0;
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}
