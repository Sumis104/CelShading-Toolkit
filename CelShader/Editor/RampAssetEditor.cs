using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(RampAsset))]
public class RampAssetEditor : Editor
{
    public override void OnInspectorGUI()
    {
        RampAsset ramp = (RampAsset)target;

        serializedObject.Update();

        EditorGUILayout.PropertyField(serializedObject.FindProperty("gradient"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("width"));

        serializedObject.ApplyModifiedProperties();

        EditorGUILayout.Space();
        EditorGUI.BeginDisabledGroup(true);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("texture"));
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space();
        if (GUILayout.Button("書き出す"))
        {
            RampBaker.Bake(ramp);
        }
    }
}
