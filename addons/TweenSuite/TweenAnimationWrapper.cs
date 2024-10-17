using Godot;

namespace Godot.TweenSuite;

/// <summary>
/// <para>TweenAnimationWrapper is a <see cref="Godot.Resource"/> that serves as bridge between a GDScript TweenSuite's TweenAnimation resource and your C# code. Useful to start a data driven <see cref="Godot.Tween"/> directly in your code.</para>
/// <para>You only have to call <c>@TweenAnimationWrapper.Setup(rootNode)</c> to create a <see cref="Godot.Tween"/> and setup any <see cref="Godot.Tweener"/> defined in the linked TweenAnimation.</para>
/// </summary>
[GlobalClass]
public partial class TweenAnimationWrapper : Resource
{
    /// <summary>
    /// <para>Link to your GDScript TweenSuite's TweenAnimation resource file.</para>
    /// </summary>
    [Export(PropertyHint.ResourceType, "TweenAnimation")]
    public Resource AnimationResource{ get; set; }

    // Name of the "apply_to_tween" method in the GDScript
    private readonly StringName _applyToTweenMethod = new StringName("apply_to_tween");
    
    /// <summary>
    /// <para>Creates a <see cref="Godot.Tween"/> and setups it with your linked TweenAnimation.</para>
    /// <para> <b>rootNode</b> is the root <see cref="Godot.Node"/> you want to tween.</para>
    /// <para> <b>bindToNode</b> will bind your Tween to your Node, killing it if your node exit the tree or is freed.</para>
    /// <para><code>
    /// public partial class YourNode : Node
    /// {
    ///    [Export] public TweenAnimationWrapper YourAnimation { get; set; }
    /// 
    ///     public void StartTweenAnimation()
    ///     {
    ///         if (YourAnimation != null)
    ///         {
    ///             Tween myTween = YourAnimation.Setup(this, true);
    ///             // Do whatever you want with the tween as usual
    ///         }
    ///     }
    /// }
    /// </code></para>
    /// </summary>
    public Tween Setup(Node rootNode, bool bindToNode = false)
    {
        if (AnimationResource != null && rootNode != null && rootNode.IsInsideTree())
        {
            Tween tween = rootNode.GetTree().CreateTween();
            if (bindToNode)
            {
                tween.BindNode(rootNode);
            }
            AnimationResource.Call(_applyToTweenMethod, tween, rootNode);
            return tween;
        }
        return null;
    }
    
    /// <summary>
    /// <para>Setups a <see cref="Godot.Tween"/> on a <see cref="Godot.Node"/> with your linked TweenAnimation.</para>
    /// <para> <b>rootNode</b> is the root Node you want to tween.</para>
    /// <para> <b>tween</b> the tween you want to setup with your TweenAnimation.</para>
    /// </summary>
    public bool ApplyToTween(Node rootNode, Tween tween)
    {
        if (AnimationResource != null && rootNode != null && tween != null)
        {
            AnimationResource.Call(_applyToTweenMethod, tween, rootNode);
            return true;
        }
        return false;
    }
}