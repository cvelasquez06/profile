#include <stdio.h>
#include <iostream>
#include <windows.h>
#include <ctime>
 
using namespace std;
#define current_path ""
#define filename ""
#define destination ""
#define users   ""
#define password ""
#define ip_address ""
#define key ""
 
int call_transfer_file()
{
    time_t rawtime;
    struct tm * timeinfo;
    char btime[20];
    time (&rawtime);
    timeinfo = localtime (&rawtime);
    strftime (btime,20,"%d%m%Y%H%M%S",timeinfo);
    char exec[290];
    sprintf(exec,"C:\\respaldos_softland\\app_backup\\winscp.exe /console /command \"option batch abort\" \"option confirm off\" \"open sftp://%s:%s@%s\" \"put %s\\%s %s%s.sql\" \"exit\"",users,password,ip_address,current_path,filename,destination,btime);
    return system(exec);
}
int main()
{
    return call_transfer_file();
}