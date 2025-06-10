using UnityEngine;

public class SingletonBPM<W> : MonoBehaviour where W : MonoBehaviour
{
    public static W instance;

    private void Awake()
    {
        if (instance != null)
        {
            gameObject.SetActive(false);
            Debug.LogError($"cannot have to instance of {typeof(W).ToString()} !", this);
            return;
        }

        instance = this as W;
    }
    private void OnEnable()
    {
        // Restore instance if lost after a scene change
        if (instance == null)
        {
            instance = this as W;
            Debug.Log($"{typeof(W)}.instance restored in OnEnable");
        }
    }
}
