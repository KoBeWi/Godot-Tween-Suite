# Godot Tween Suite

**This addons is work in progress!**

It adds 3 things:
- TweenNode, which is a Node wrapper for Tween. It allows to place a Tween in your scene and it will persist. You can define animation in code or using a new resource, which is
- TweenAnimation, a resource that can append Tweeners to a Tween, so you don't need to set them up from code. It supports all Tweeners and methods, but due to being serializable, the workflow is a bit different. Also there are no methods to create an animation, instead you should use the new
- TweenAnimationEditor, which allows creating and editing TweenAnimation, similar to the AnimationPlayer editor. It supports basic playback, but since Tweens don't allow seeking, there is no proper timeline.

The TweenNode can be used as Tween or it can create a persistent Tween (i.e. one that doesn't invalidate after finishing) via a static method. The TweenAnimation can either be applied to TweenNode or a plain Tween, so you can create and use a TweenAnimation without using TweenNode. All components are independent.

As said above, this is heavily under development and especially the editor is very faulty. The TweenNode and TweenAnimation format should be somewhat finalized though, so you can experiment with them and possibly give suggestions.

Proper description and documentation coming once I finish this, in the meantime here's a preview of the editor:

https://vxtwitter.com/KoBeWi_/status/1752678430728917164