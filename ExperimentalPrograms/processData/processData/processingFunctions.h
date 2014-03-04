//
//  processingDunctions.h
//  processData
//
//  Created by Marc Ericson Santos on 3/3/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#ifndef processData_processingDunctions_h
#define processData_processingDunctions_h

struct twoStr
{
    char response[30];
    char word[30];
};

int readLine(FILE* f, char* line, size_t size);

struct twoStr separateStr(char* response);


#endif
