#include <stdio.h>
#include <string.h>
#include "processingFunctions.h"

int main(int argc, const char *argv[])
{
//Calculate response time and note answer if YES or NO
	FILE* f = fopen("zhang.dat", "r");
	
    char line[500];
    int lineData[1000][6];
    double secData[1000];
    char response[1000][60];
    int ind1 = 1;
    int minDiff[1000];
    double secDiff[1000];
    struct twoStr s[1000];
	
	while(readLine(f, line, 128))
	{
        
		sscanf
        (
			line, 
			"%d-%d-%d %d:%d:%lf;%d;%s",
			&lineData[ind1][0],
			&lineData[ind1][1],
			&lineData[ind1][2],
            &lineData[ind1][3],
            &lineData[ind1][4],
            &secData[ind1],
            &lineData[ind1][5],
            response[ind1]
		);
        
        if (ind1%2==0)
        {
            minDiff[ind1] = lineData[ind1][4] - lineData[ind1-1][4];
            secDiff[ind1] = secData[ind1]-secData[ind1-1];
            
            if (minDiff[ind1]==1)
            {
                secDiff[ind1] = secDiff[ind1] + 60;
            }
            
            s[ind1] = separateStr(response[ind1]);
            
            /*printf
            (
             "%d %lf %s %s\n",
             lineData[ind1][0],
             secDiff[ind1],
             s[ind1].response,
             s[ind1].word
            );*/
        }
        
        ind1++;
	}
    
	fclose(f);
//-------------------------------------------------------------------//
    
//Get the list of words and put in an array
    char dictionary[500][60];
    int ind2 = 1;
    FILE* g = fopen("wordList.dat", "r");
    while(readLine(g, line, 128))
	{
		sscanf(line,"%s", dictionary[ind2]);
        //printf("%s\n",dictionary[ind2]);
        ind2++;
    }
    fclose(g);
//-------------------------------------------------------------------//

//Tabulate the response times for each word
    double time[1000][3]={0};
    int answer[1000][3]={0};
    int timeColumn = 0;
    
    for (int a=2; a<ind1; a=a+2)
    {
        
        for (int b=1; b<ind2; b++)
        {
            if (strcmp(dictionary[b],s[a].word)==0)
            {
                time[b][timeColumn] = secDiff[a];
                if (strcmp("YES",s[a].response)==0)
                {
                    answer[b][timeColumn] = 1;
                }
                //printf("%d\n", b);
            }
        }
        
        if (a%100==0)
        {
            timeColumn++;
        }
    }
//-------------------------------------------------------------------//

    for (int c=1; c<51; c++)
    {
        printf("%s %f %f %f %d %d %d\n",
               dictionary[c],
               time[c][0],
               time[c][1],
               time[c][2],
               answer[c][0],
               answer[c][1],
               answer[c][2]
               );
    }

//Get the array of markers viewed per day
    FILE* log = fopen("AccData.dat", "r");
    
    int accData[6];
    double acceleration[3];
    double secAccData;
    int seen[30][10];
    int currentDay = 0;
    int currentColumn = 0;
    while(readLine(log, line, 128))
	{
		sscanf
        (
         line,
         "%d-%d-%d %d:%d:%lf;%d;%lf;%lf;%lf",
         &accData[0],
         &accData[1],
         &accData[2],
         &accData[3],
         &accData[4],
         &secAccData,
         &accData[5],
         &acceleration[0],
         &acceleration[1],
         &acceleration[2]
         );
        
        if (currentDay!=accData[0]) {
            currentDay = accData[0];
            currentColumn++;
        }
        if (accData[5]!=-1) {
            seen[accData[5]][currentColumn]=1;
        }
    }
//-------------------------------------------------------------------//
    
    for (int c=0; c<30; c++)
    {
        printf("%d: %d %d %d %d %d\n",
               c,
               seen[c][1],
               seen[c][2],
               seen[c][3],
               seen[c][4],
               seen[c][5]
               );
     }
    
    return 0;
}
