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

    public int iLevel;
    public int iHardLevel;
    public int[] iTaggsPerHardLvl;
    public int[] iScorePerLvl;
    public int[] iScorePerHardLvl;

    public GameData(PlayerData player)
    {
        iLevel = player.iLevelPlayer;
        iHardLevel = player.iHardLevelPlayer;
        iTaggsPerHardLvl = new int[player.iTaggsPerHardLvlPlayer.Length];
        if (player.iTaggsPerHardLvlPlayer != null)
        {
            for (int i = 0; i < player.iTaggsPerHardLvlPlayer.Length; i++)
            {
                iTaggsPerHardLvl[i] = player.iTaggsPerHardLvlPlayer[i];
            }
        }
        else
        {
            iTaggsPerHardLvl = null;
        }
        iScorePerLvl = new int[player.iScorePerLvPlayerl.Length];
        if (player.iScorePerLvPlayerl != null)
        {
            for (int i = 0; i < player.iScorePerLvPlayerl.Length; i++)
            {
                iScorePerLvl[i] = player.iScorePerLvPlayerl[i];
            }
        }
        else
        {
            iScorePerLvl = null;
        }
        iScorePerHardLvl = new int[player.iScorePerHardLvlPlayer.Length];
        if (player.iScorePerHardLvlPlayer != null)
        {
            for (int i = 0; i < player.iScorePerHardLvlPlayer.Length; i++)
            {
                iScorePerHardLvl[i] = player.iScorePerHardLvlPlayer[i];
            }
        }
        else
        {
            iScorePerHardLvl = null;
        }
    }
}

