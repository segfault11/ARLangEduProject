#include <stdio.h>
#include <string.h>
#include "processingFunctions.h"

int main(int argc, const char *argv[])
{
//Calculate response time and note answer if YES or NO
	
    FILE* log = fopen("flipdata/Yusuke_ShimizuAccData.dat", "r");
    FILE* f = fopen("recogdata/Atsushi_KeyakiRecogGameButData.dat", "r");
	FILE* but = fopen("flipdata/Yusuke_ShimizuButData.dat", "r");
    
    char line[500];
    int lineData[5000][6];
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
    char dictionary[100][60];
    int ind2 = 1;
    FILE* g = fopen("recogdata/wordList.dat", "r");
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
                if (strcmp("NO",s[a].response)==0)
                {
                    answer[b][timeColumn] = 2;
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

    for (int c=1; c<91; c++)
    {
        printf("%s,%f,%f,%f,%d,%d,%d\n",
               dictionary[c],
               time[c][0],
               time[c][1],
               time[c][2],
               answer[c][0],
               answer[c][1],
               answer[c][2]
               );
    }

//Get the array of markers viewed per day, and how long it was viewed
    
    int accData[6];
    double acceleration[3];
    double secAccData;
    int seen[30][10];
    int seenDur[30][10];
    int seenNot[10];
    int currentDay = 0;
    int currentColumn = 0;
    int lineCount[10];
    
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
            /*printf( "%d-%d-%d %d:%d\n",
                   accData[0],
                   accData[1],
                   accData[2],
                   accData[3],
                   accData[4]
                   );*/
            currentColumn++;
        }
        
        lineCount[currentColumn]++;
        
        if (accData[5]!=-1) {
            seen[accData[5]][currentColumn]=1;
            seenDur[accData[5]][currentColumn]++;
        }else{
            seenNot[currentColumn]++;
        }
        
    }
//-------------------------------------------------------------------//
    /*
    for (int c=0; c<30; c++)
    {
        printf("%d:,%d,%d,%d,%d,%d,count:,%d,%d,%d,%d,%d\n",
               c,
               seen[c][1],
               seen[c][2],
               seen[c][3],
               seen[c][4],
               seen[c][5],
               seenDur[c][1],
               seenDur[c][2],
               seenDur[c][3],
               seenDur[c][4],
               seenDur[c][5]
               );
     }
    
    printf("-1 count:,%d,%d,%d,%d,%d\n",
           seenNot[1],
           seenNot[2],
           seenNot[3],
           seenNot[4],
           seenNot[5]
           );
    
    printf("Total count:,%d,%d,%d,%d,%d\n",
           lineCount[1],
           lineCount[2],
           lineCount[3],
           lineCount[4],
           lineCount[5]
           );
    */
    
    fclose(log);

//Buttons tapped per day
    currentDay = 0;
    currentColumn = 0;
    ind1 = 0;
    int tapped[4][10];
    
    while(readLine(but, line, 128))
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
        
        if (currentDay!=lineData[ind1][0])
        {
            currentDay = lineData[ind1][0];
            currentColumn++;
        }
        
        if (strcmp("LISTEN",response[ind1])==0)
        {
            tapped[0][currentColumn]++;
        }
        else if (strcmp("TRANSLATE",response[ind1])==0)
        {
            tapped[1][currentColumn]++;
        }
        else if (strcmp("DESCRIBE",response[ind1])==0)
        {
            tapped[2][currentColumn]++;
        }
        //printf("%d %lf\n",ind1,secData[ind1]);
        ind1++;
	
    
    }
    //printf("LISTEN,%d,%d,%d,%d,%d\n",tapped[0][1],tapped[0][2],tapped[0][3],tapped[0][4],tapped[0][5]);
    //printf("TRANSLATE,%d,%d,%d,%d,%d\n",tapped[1][1],tapped[1][2],tapped[1][3],tapped[1][4],tapped[1][5]);
    //printf("DESCRIBE,%d,%d,%d,%d,%d\n",tapped[2][1],tapped[2][2],tapped[2][3],tapped[2][4],tapped[2][5]);
    
    fclose(but);
//-------------------------------------------------------------------//
    
    return 0;

}
