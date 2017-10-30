#include "engine.h"

#include <mach-o/dyld.h>

string
resources_dir_path()
{
    static string dir_path = "";

    if (dir_path == "")
    {
        char buff[1024];
        uint32_t size = 1024;

        _NSGetExecutablePath(buff, &size);

        string path(buff);

        auto pos = path.rfind('/');
        pos = path.rfind('/', pos - 1);

        dir_path = path.substr(0, pos) + "/Resources/";
    }

    return dir_path;
}
