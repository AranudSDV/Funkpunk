#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public class ButtonAttribute : PropertyAttribute
{
    public readonly string methodName;

    public ButtonAttribute(string methodName)
    {
        this.methodName = methodName;
    }
}

#if UNITY_EDITOR
[CustomPropertyDrawer(typeof(ButtonAttribute))]
public class ButtonAttributeDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        ButtonAttribute buttonAttribute = attribute as ButtonAttribute;

        if (GUI.Button(position, buttonAttribute.methodName))
        {
            var target = property.serializedObject.targetObject;
            var method = target.GetType().GetMethod(buttonAttribute.methodName,
                System.Reflection.BindingFlags.Instance |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.NonPublic);
            if (method != null)
            {
                method.Invoke(target, null);
            }
        }
    }
}
#endif