using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class test : MonoBehaviour {
    public InputField rate;
    public InputField num;
    public Button sure;
    public GameObject Model;
    private GameObject ModelRoot;
    string[] animationClip = { "daiji","gongji01","jineng01","jineng02","jineng03","shengli","xuanyun","yidong"};

	// Use this for initialization
	void Start () {            
            sure.onClick.AddListener(OnButtonSure);
    }
    void OnButtonSure()
    {
        int n =int.Parse(num.text);
        int r = int.Parse(rate.text);

        Application.targetFrameRate = r;
        LoadModels(n);
    }
    void LoadModels(int num)
    {   
        if(ModelRoot == null)
        {
            ModelRoot = new GameObject("ModelRoot");
        }
        for(int i = 0; i<ModelRoot.transform.childCount;i++)
        {
            Destroy(ModelRoot.transform.GetChild(i).gameObject);            
        }
        
        for(int i = 0;i<num;i++)
        {
            GameObject temp = GameObject.Instantiate(Model, ModelRoot.transform);
            temp.transform.position = new Vector3(Random.Range(-5, 5), Random.Range(-5, 5), Random.Range(-5, 20));
            Animation anim = temp.GetComponent<Animation>();
            int n = anim.GetClipCount();
            string aid = animationClip[Random.Range(0, animationClip.Length - 1)];
            AnimationState state = anim[aid];
            state.speed = 2;
            state.wrapMode = WrapMode.Loop;
            anim.Play(aid);
        }
    }
    // Update is called once per frame
    void Update () {
		
	}
}
