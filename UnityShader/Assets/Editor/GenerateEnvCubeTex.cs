using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GenerateEnvCubeTex : ScriptableWizard
{
    public Transform renderFromPosition;
    public Cubemap cubemap;

    private void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }

    private void OnWizardCreate()
    {
        GameObject go = new GameObject( "CubemapCamera");
        go.AddComponent<Camera>();
        // place it on the object
        go.transform.position = renderFromPosition.position;
        // render into cubemap		
        go.GetComponent<Camera>().RenderToCubemap(cubemap);
		
        // destroy temporary camera
        DestroyImmediate( go );
    }

    [MenuItem("GameObject/Render into Cubemap")]
    static void GenerateCubemap()
    {
        ScriptableWizard.DisplayWizard<GenerateEnvCubeTex>("GenerateCubemap", "Generate");
    }
}
