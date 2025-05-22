using UnityEngine;

public class Singleton<T> : MonoBehaviour where T : MonoBehaviour
{
    public static T instance;

    private void Awake()
    {
        if (instance != null)
        {
            gameObject.SetActive(false);
            Debug.LogError($"cannot have to instance of {typeof(T).ToString()} !", this);
            return;
        }

        instance = this as T;
    }
}
