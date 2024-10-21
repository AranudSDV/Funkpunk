using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SC_FieldOfView))]

public class SC_FieldOfViewEditor : Editor
{
    
    private void OnSceneGUI()
    {
        SC_FieldOfView fov = (SC_FieldOfView)target;
        Handles.color = Color.white;
        Handles.DrawWireArc(fov.transform.position, Vector3.up, Vector3.forward, 360, fov.FRadius);

        Vector3 viweAngle01 = DirectionFromAngle(fov.transform.eulerAngles.y, -fov.FAngle / 2);
        Vector3 viweAngle02 = DirectionFromAngle(fov.transform.eulerAngles.y, fov.FAngle / 2);

        Handles.color = Color.yellow;
        Handles.DrawLine(fov.transform.position, fov.transform.position + viweAngle01 * fov.FRadius);
        Handles.DrawLine(fov.transform.position, fov.transform.position + viweAngle02 * fov.FRadius);

        if (fov.BCanSee)
        {
            Handles.color = Color.green;
            Handles.DrawLine(fov.transform.position, fov.GOPlayerRef.transform.position);
        }
    }

    private Vector3 DirectionFromAngle(float eulerY, float angleInDegrees)
    {
        angleInDegrees += eulerY;

        return new Vector3(Mathf.Sin(angleInDegrees * Mathf.Deg2Rad), 0, Mathf.Cos(angleInDegrees * Mathf.Deg2Rad));
    }
    
}
