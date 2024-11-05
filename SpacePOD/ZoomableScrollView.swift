//the code includes double-tap to zoom functionality
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
   private var content: Content

   init(@ViewBuilder content: () -> Content) {
       self.content = content()
   }

   func makeUIView(context: Context) -> UIScrollView {
       let scrollView = UIScrollView()
       scrollView.delegate = context.coordinator
       scrollView.maximumZoomScale = 10
       scrollView.minimumZoomScale = 1
       scrollView.bouncesZoom = true
       scrollView.showsHorizontalScrollIndicator = false
       scrollView.showsVerticalScrollIndicator = false
       scrollView.backgroundColor = .clear

       // UIHostingController for SwiftUI content
       let hostedView = context.coordinator.hostingController.view!
       hostedView.translatesAutoresizingMaskIntoConstraints = true
       hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       hostedView.frame = scrollView.bounds
       hostedView.backgroundColor = .clear
       scrollView.addSubview(hostedView)

       // Add double-tap gesture recognizer
       let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap))
       doubleTapGesture.numberOfTapsRequired = 2
       scrollView.addGestureRecognizer(doubleTapGesture)

       return scrollView
   }

   func makeCoordinator() -> Coordinator {
       return Coordinator(hostingController: UIHostingController(rootView: self.content))
   }

   func updateUIView(_ uiView: UIScrollView, context: Context) {
       context.coordinator.hostingController.rootView = self.content
       assert(context.coordinator.hostingController.view.superview == uiView)
   }

   // MARK: - Coordinator

   class Coordinator: NSObject, UIScrollViewDelegate {
       var hostingController: UIHostingController<Content>

       init(hostingController: UIHostingController<Content>) {
           self.hostingController = hostingController
       }

       func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return hostingController.view
       }

       // Handle double-tap to reset zoom
       @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
           if let scrollView = sender.view as? UIScrollView {
               if scrollView.zoomScale == 1.0 {
                   scrollView.setZoomScale(6.0, animated: true)
               }
               else {
                   scrollView.setZoomScale(1.0, animated: true)
               }
           }
       }
   }
}
