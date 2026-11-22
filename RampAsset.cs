using UnityEngine;

[CreateAssetMenu(fileName = "Ramp_New", menuName = "CelShader/Ramp")]
public class RampAsset : ScriptableObject
{
    public Gradient gradient = new Gradient();

    public int width = 256;

    public Texture2D texture;
}
