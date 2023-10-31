module Read

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;

// Create a list of all file locations in the project
list[loc] getFiles(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[loc] fileLocs = [f | f <- files(model.containment), isCompilationUnit(f)];
    return fileLocs;
}

// Convert a file into an array
public list[str] file2Array(loc file){
    return readFileLines(file);
}
