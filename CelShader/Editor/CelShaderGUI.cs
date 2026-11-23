using UnityEngine;
using UnityEditor;
using System.IO;

public class CelShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        EditorGUILayout.LabelField("ベース", EditorStyles.boldLabel);
        MaterialProperty basecolor = FindProperty("_BaseColor", properties);
        materialEditor.ShaderProperty(basecolor, "ベースの色");
        MaterialProperty maintex = FindProperty("_MainTex", properties);
        materialEditor.ShaderProperty(maintex, "テクスチャー");
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("影", EditorStyles.boldLabel);
        MaterialProperty rampmap = FindProperty("_RampMap", properties);
        materialEditor.ShaderProperty(rampmap, "ランプ");
        DrawRampEditor(rampmap);
        MaterialProperty shadeOffset = FindProperty("_ShadeOffset", properties);
        materialEditor.ShaderProperty(shadeOffset, "影の境目");
        MaterialProperty shadingStrength = FindProperty("_ShadingStrength", properties);
        materialEditor.ShaderProperty(shadingStrength, "陰影の強さ");
        MaterialProperty receiveShadow = FindProperty("_ReceiveShadow", properties);
        materialEditor.ShaderProperty(receiveShadow, "落ちる影の強さ");
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("光", EditorStyles.boldLabel);
        MaterialProperty ambientStrength = FindProperty("_AmbientStrength", properties);
        materialEditor.ShaderProperty(ambientStrength, "環境光の強さ");
        MaterialProperty rimColor = FindProperty("_RimColor", properties);
        materialEditor.ShaderProperty(rimColor, "リムの色");
        MaterialProperty rimWidth = FindProperty("_RimWidth", properties);
        materialEditor.ShaderProperty(rimWidth, "リムの幅");
        MaterialProperty rimBlur = FindProperty("_RimBlur", properties);
        materialEditor.ShaderProperty(rimBlur, "リムのぼかし");
        MaterialProperty rimStrength = FindProperty("_RimStrength", properties);
        materialEditor.ShaderProperty(rimStrength, "リムの強さ");
        MaterialProperty highlightmask = FindProperty("_HighlightMask", properties);
        materialEditor.ShaderProperty(highlightmask, "ハイライトのマスク");
        MaterialProperty highlightcolor = FindProperty("_HighlightColor", properties);
        materialEditor.ShaderProperty(highlightcolor, "ハイライトの色");
        MaterialProperty highlightsize = FindProperty("_HighlightSize", properties);
        materialEditor.ShaderProperty(highlightsize, "ハイライトの大きさ");
        MaterialProperty highlightblur = FindProperty("_HighlightBlur", properties);
        materialEditor.ShaderProperty(highlightblur, "ハイライトのぼかし");
        MaterialProperty highlightstrength = FindProperty("_HighlightStrength", properties);
        materialEditor.ShaderProperty(highlightstrength, "ハイライトの強さ");

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("アウトライン", EditorStyles.boldLabel);
        MaterialProperty outlineColor = FindProperty("_OutlineColor", properties);
        materialEditor.ShaderProperty(outlineColor, "線の色");
        MaterialProperty outlineWidth = FindProperty("_OutlineWidth", properties);
        materialEditor.ShaderProperty(outlineWidth, "線の太さ");
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("描画", EditorStyles.boldLabel);
        MaterialProperty cull = FindProperty("_Cull", properties);
        materialEditor.ShaderProperty(cull, "両面表示");
        MaterialProperty alphaTest = FindProperty("_AlphaTest", properties);
        materialEditor.ShaderProperty(alphaTest, "切り抜き");
        if (alphaTest.floatValue > 0.5f)
        {
            EditorGUI.indentLevel++;
            MaterialProperty cutoff = FindProperty("_Cutoff", properties);
            materialEditor.ShaderProperty(cutoff, "切り抜きの閾値");
            EditorGUI.indentLevel--;
        }
    }
    void DrawRampEditor(MaterialProperty rampProp)
    {
        RampAsset rampAsset = null;
        Texture tex = rampProp.textureValue;
        if (tex != null)
        {
            string texPath = AssetDatabase.GetAssetPath(tex);
            string assetPath = Path.ChangeExtension(texPath, ".asset");
            rampAsset = AssetDatabase.LoadAssetAtPath<RampAsset>(assetPath);
        }

        if (rampAsset == null)
        {
            EditorGUILayout.HelpBox("このランプはグラデーションから作られていません", MessageType.Info);

            if (GUILayout.Button("グラデーションで作る"))
            {
                string path = EditorUtility.SaveFilePanelInProject("ランプの保存先", "Ramp_New", "asset", "保存先を選んでください");
                if (!string.IsNullOrEmpty(path))
                {
                    rampAsset = ScriptableObject.CreateInstance<RampAsset>();
                    AssetDatabase.CreateAsset(rampAsset, path);
                    RampBaker.Bake(rampAsset);
                    rampProp.textureValue = rampAsset.texture;
                }
            }
            return;
        }

        SerializedObject so = new SerializedObject(rampAsset);
        so.Update();

        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PropertyField(so.FindProperty("gradient"), new GUIContent("グラデーション"));

        if (EditorGUI.EndChangeCheck())
        {
            so.ApplyModifiedProperties();
            RampBaker.Bake(rampAsset);
            rampProp.textureValue = rampAsset.texture;
        }


    }

}
