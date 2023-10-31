module Volume

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

int mainVolume(loc projectLocation){
    list[loc] fileLocations = getFiles(projectLocation);
    return countLinesProject(fileLocations);
}

// Count total number of lines in a project
public int countLinesProject(list[loc] fileLocations){
    int lines = 0;
    for (l <- fileLocations){
        lines += countLinesFile(l);
    }
    return lines;
}

// Count total number of lines in a file
public int countLinesFile(loc fileLocation){
    list[str] file = file2Array(fileLocation);
    int lines = size(file);

    return lines;
}

public int countCommentsProject(list[loc] fileLocations){
    int lines = 0;
    for (l <- fileLocations){
        lines += countCommentsFile(l);
    }
    return lines;
}

public int countCommentsFile(loc fileLocation){
    list[str] file = file2Array(fileLocation);
    int comments = 0;
    for (s <- file){
        if (/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s) comments += 1;
    }

    return comments;
}

