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
public list[str] file2Array(loc file) {
    return readFileLines(file);
}

// Delete the start and end of multiline comments from a line.
public tuple[bool, str] deleteMultiComments(bool inComment, str s) {
    int endLine = size(s);
    str newString = s;
    int indexStartComment = findFirst(s, "/*");
    int indexEndComment = findFirst(s, "*/");

    // Catches lines like: "comment */", "comment */ code /* comment */"
    if ((indexEndComment < indexStartComment || indexStartComment == -1)
            && indexEndComment != -1) {
        inComment = false;
        newString = newString[indexEndComment + 2..endLine];
    }

    // Catches lines like: "/* comment", "/* comment */ code /* comment"
    while (indexStartComment != -1) {
        // Catches: "code /* comment"
        if (indexEndComment == -1) {
            inComment = true;
            newString = newString[0..indexStartComment];
        }
        // Catches: "code /* comment */ code"
        else {
            inComment = false;
            newString = newString[0..indexStartComment] + newString[indexEndComment + 2..endLine];
        }
        indexStartComment = findFirst(newString, "/*");
    }

    return <inComment, newString>;
}

// Delete a single line comment from a line.
// public str deleteSingleComment(str s) {
//     list[str] stringSlices = [];

//     str newString = s;


//     return newString;
// }

public list[str] deleteComments(list[str] file) {
    // Filter all single line comments without code before the comment and empty lines.
    // i.e. "// comment" gets filtered out, but "code // comment" is kept.
    file = [s | str s <- file, /^\s*\/\/.*/ !:= s, /^\s*$/ !:= s];
    int lastArray = size(file) - 1;
    list[str] newFile = [];
    bool inComment = false;
    // bool inString = false;

    for (s <- file){
        bool hasCommentStart = contains(s, "/*");
        bool hasCommentEnd = contains(s, "*/");
        if (inComment && !hasCommentEnd) {
            continue;
        }
        // if (inString) {
        //     newFile = newFile + s;
        //     continue;
        // }
        
        if (hasCommentEnd || hasCommentStart) {
            println("in: <s>");
            <inComment, s> = deleteMultiComments(inComment, s);
            println("out: <s>");
        }
        newFile = newFile + s;
    }
    newFile = [s | str s <- newFile, /^\s*$/ !:= s];

    return newFile;
}

