//
//  processingFunctions.c
//  processData
//
//  Created by Marc Ericson Santos on 3/3/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include "processingFunctions.h"

int readLine(FILE* f, char* line, size_t size)
{
	char c;
    
	int i = 0;
    
	do
	{
		c = fgetc(f);
		
		if (i > size)
		{
			return 1;
		}
        
		line[i] = c;
		i++;
	}
	while (c != '\n' && c != EOF);
    
	line[i] = '\0';
    
	if (c == EOF)
	{
	    return 0;
	}
    
	return 1;
}

struct twoStr separateStr(char* string)
{
    //char *p;
    //p = strtok(response,";");
    struct twoStr s;
    
    strcpy(s.response, strtok(string,";"));
    strcpy(s.word, strtok(NULL,";"));
    
    return s;
}

