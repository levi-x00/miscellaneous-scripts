for ns in namespace1 namespace2; do
  echo "Namespace: $ns"
  deployments=$(kubectl get deploy -n $ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
  for deploy in $deployments; do
    echo "Deployment: $deploy"
    
    # Get pods for this deployment
    pods=$(kubectl get pods -n $ns -l app=$deploy -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort -u)
    
    # Get instance types for nodes
    for node in $pods; do
      instance_type=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/instance-type}')
      echo "- Node: $node, Instance Type: $instance_type"
    done
    
    echo ""
  done
done
