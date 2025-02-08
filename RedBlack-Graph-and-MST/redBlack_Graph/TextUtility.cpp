#include "TextUtility.h"

/* convertStringIntoType(..) e readTwoWordsbyFile(..)
 * si trovano in TextUtility.h poiché non è stato possibile separare la loro definizione dalla loro implementazione
 */

void clearTerminal(){
    #ifdef __linux__
        cout <<"\e[1;1H\e[2J";
    #elif __APPLE__ 
        cout <<"\e[1;1H\e[2J";
    #elif _WIN32
        system("cls");
    #endif
}

void waitKeypress(){
    #ifdef __linux__
        cout << endl;
        cout << "Scrivere un carattere e premere invio per continuare . . ." << endl;
        char input;
        std::cin >> input;
    #elif __APPLE__ 
        cout << endl;
        cout << "Scrivere un carattere e premere invio per continuare . . ." << endl;
        char input;
        std::cin >> input;
    #elif _WIN32
        system("pause");
    #endif
}
