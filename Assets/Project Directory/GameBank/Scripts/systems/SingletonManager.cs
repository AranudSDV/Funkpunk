using UnityEngine;

public class SingletonManager<Y> : MonoBehaviour where Y : MonoBehaviour
{
    public static Y instance;

    private void Awake()
    {
        if (instance != null)
        {
            gameObject.SetActive(false);
            Debug.LogError($"cannot have to instance of {typeof(Y).ToString()} !", this);
            return;
        }

        instance = this as Y;
    }
    private void OnEnable()
    {
        // Restore instance if lost after a scene change
        if (instance == null)
        {
            instance = this as Y;
            Debug.Log($"{typeof(Y)}.instance restored in OnEnable");
        }
    }
}
