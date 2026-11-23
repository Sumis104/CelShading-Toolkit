using System.IO;
using UnityEngine;
using UnityEditor;

public static class RampBaker
{
    public static void Bake(RampAsset ramp)
    {
        Texture2D tex = new Texture2D(ramp.width, 4, TextureFormat.RGBA32, false);

        for (int x = 0; x < ramp.width; x++)
        {
            float t = x / (float)(ramp.width - 1);

            Color c = ramp.gradient.Evaluate(t);

            for (int y = 0; y < 4; y++)
            {
                tex.SetPixel(x,y,c);
            }
        }
        tex.Apply();

        string assetPath = AssetDatabase.GetAssetPath(ramp);
        string pngPath = Path.ChangeExtension(assetPath, ".png");

        File.WriteAllBytes(pngPath,tex.EncodeToPNG());
        Object.DestroyImmediate(tex);

        AssetDatabase.ImportAsset(pngPath);
        TextureImporter importer = (TextureImporter)AssetImporter.GetAtPath(pngPath);
        importer.wrapMode = TextureWrapMode.Clamp;
        importer.mipmapEnabled = false;
        importer.textureCompression = TextureImporterCompression.Uncompressed;
        importer.SaveAndReimport();

        ramp.texture = AssetDatabase.LoadAssetAtPath<Texture2D>(pngPath);
        EditorUtility.SetDirty(ramp);
        AssetDatabase.SaveAssets();
    }
}
