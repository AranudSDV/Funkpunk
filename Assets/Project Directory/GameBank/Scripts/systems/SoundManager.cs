using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using System;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using FMODUnity;

public class SoundManager : MonoBehaviour
{
    [SerializeField] private AudioClip[] sfxSounds;
    [SerializeField] private AudioClip[] musicSounds;
    [SerializeField] private AudioSource sfxSource, musicSource;
    [SerializeField] private FMODUnity.EventReference fmodEvent;
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }

    public void PlaySFXButton()
    {
        int i = Hasard(0, 3);
        AudioClip s = sfxSounds[i];

        if (s == null)
        {
            Debug.Log("Sound Not Found");
        }
        else
        {
            sfxSource.PlayOneShot(s);
        }
    }

    public void PlayMusic(string sfx_music)
    {
        foreach (AudioClip s in musicSounds)
        {
            if (s.name == sfx_music)
            {
                musicSource.clip = s;
                musicSource.Play();
            }
        }
    }

    public void MusicVolume(GameObject GO)
    {
        Slider slider = GO.GetComponent<Slider>();
        float volume = slider.value;
        musicSource.volume = volume;
    }
    public void SFXVolume(GameObject GO)
    {
        Slider slider = GO.GetComponent<Slider>();
        float volume = slider.value;
        sfxSource.volume = volume;
    }
}
