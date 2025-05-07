using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using System;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using FMODUnity;
using FMOD.Studio;

public class SoundManager : MonoBehaviour
{
    /*[SerializeField] private AudioClip[] sfxSounds;
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
    }*/
    public static SoundManager Instance { get; private set; }
    private Dictionary<string, float> soundCooldowns = new Dictionary<string, float>();
    private float cooldownDuration = 0.05f;
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
    public void PlayOneShot(EventReference eventReference)
    {
        string eventPath = eventReference.Guid.ToString();
        if (CanPlaySound(eventPath))
        {
            RuntimeManager.PlayOneShot(eventPath);
            soundCooldowns[eventPath] = Time.time + cooldownDuration;
        }
    }
    public EventInstance CreateEventInstance(EventReference eventReference)
    {
        return RuntimeManager.CreateInstance(eventReference);
    }
    private bool CanPlaySound(string eventPath)
    {
        if (!soundCooldowns.ContainsKey(eventPath) || Time.time >= soundCooldowns[eventPath])
        {
            return true;
        }
        return false;
    }
}
