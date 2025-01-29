using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerData : MonoBehaviour
{
    public int iLevelPlayer;
    public int[] iStarsPlayer = new int[15]; //1 is true 0 is false, 5per lvl
    public int[] iScorePerLvlPlayer = new int[3];
    public int iLanguageNbPlayer; // 0 is english, 1 is french

    public void SaveGame()
    {
        SaveSystem.SaveGame(this);
    }

    public void LoadGame()
    {
        GameData data = SaveSystem.LoadGame();

        iLevelPlayer = data.iLevel;
        iScorePerLvlPlayer = data.iScorePerLvl;
        iLanguageNbPlayer = data.iLanguageNb;
        iStarsPlayer = data.iStars;
    }
}
