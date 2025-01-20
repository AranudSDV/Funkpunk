using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData
{

    public int iLevelPlayer;
    public int iHardLevelPlayer;
    public int[] iTaggsPerHardLvlPlayer;
    public int[] iScorePerLvPlayerl;
    public int[] iScorePerHardLvlPlayer;
    public int iLanguageNbPlayer;

    public int iLevel;
    public int[] iScorePerLvl;
    public int[] iStars; //0 is true 1 is false
    public int iLanguageNb;

    public GameData(PlayerData player)
    {
        iLanguageNb = player.iLanguageNbPlayer;
        iLevel = player.iLevelPlayer;
        iScorePerLvl = new int[player.iScorePerLvlPlayer.Length];
        iStars = new int[player.iStarsPlayer.Length];
        if (player.iScorePerLvlPlayer != null)
        {
            for (int i = 0; i < player.iScorePerLvlPlayer.Length; i++)
            {
                iScorePerLvl[i] = player.iScorePerLvlPlayer[i];
            }
        }
        else
        {
            iScorePerLvl = null;
        }
    }
}

