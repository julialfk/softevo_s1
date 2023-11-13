module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Volume;
import Duplication;

int main() {
    int lines = countLinesProject(|project://smallsql0.21_src/test|);
    println("lines: <lines>");
    real duplicates = countDuplicates(|project://smallsql0.21_src/test|, lines);
    println("duplicate percentage: <duplicates * 100>");
    return 0;
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}
