using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerData : MonoBehaviour
{
    public int iLevelPlayer;
    public int iHardLevelPlayer;
    public int[] iTaggsPerHardLvlPlayer;
    public int[] iScorePerLvPlayerl;
    public int[] iScorePerHardLvlPlayer;
    public int iLanguageNbPlayer;

    public void SaveGame()
    {
        SaveSystem.SaveGame(this);
    }

    public void LoadGame()
    {
        GameData data = SaveSystem.LoadGame();

        iLevelPlayer = data.iLevel;
        iHardLevelPlayer = data.iHardLevel;
        iTaggsPerHardLvlPlayer = data.iTaggsPerHardLvl;
        iScorePerLvPlayerl = data.iScorePerLvl;
        iScorePerHardLvlPlayer = data.iScorePerHardLvl;
        iLanguageNbPlayer = data.iLanguageNb;
    }
}
