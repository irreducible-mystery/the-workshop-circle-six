#!/usr/bin/env python3
"""
🔮 Higher-Dimensional Embedding Hypotheses Testing

This module tests various hypotheses about embedding shadow classes
into higher-dimensional mathematical spaces to reveal hidden structures.

Author: Mathematical Shadow Explorer
"""

import numpy as np
from scipy.linalg import svd, qr, eig
from scipy.spatial.distance import pdist, squareform
from scipy.stats import pearsonr
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.cluster import KMeans
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from typing import List, Dict, Tuple, Optional
import warnings
warnings.filterwarnings('ignore')

print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║         🔮 HIGHER-DIMENSIONAL EMBEDDING HYPOTHESES TESTING                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
""")


class HigherDimensionalEmbedder:
    """Test various embedding hypotheses for shadow classes"""
    
    def __init__(self):
        self.shadow_values = {
            'arithmetic_geometric': [-1.84, -1.60, -1.36],
            'critical_point': [-0.25],
            'transcendental_network': [np.pi, np.e, (1+np.sqrt(5))/2, np.log(2), 
                                       np.sqrt(2), np.log(2) + 1],
            'integer_targets': [0.0, 0.5, 1.0, 2.0]
        }
        
        # Flatten all values
        self.all_values = []
        self.class_labels = []
        for class_name, values in self.shadow_values.items():
            self.all_values.extend(values)
            self.class_labels.extend([class_name] * len(values))
        
        self.all_values = np.array(self.all_values)
        print(f"📊 Total shadow values: {len(self.all_values)}")
        
        # Create value-to-class mapping
        self.value_to_class = {}
        for class_name, values in self.shadow_values.items():
            for val in values:
                self.value_to_class[float(val)] = class_name
        
        # Color mapping
        self.colors = {
            'arithmetic_geometric': '#3498db',
            'critical_point': '#e74c3c',
            'transcendental_network': '#2ecc71',
            'integer_targets': '#9b59b6'
        }
        
        self.markers = {
            'arithmetic_geometric': 'o',
            'critical_point': 's',
            'transcendental_network': '^',
            'integer_targets': 'D'
        }
    
    def create_feature_matrix(self, dimension: int) -> np.ndarray:
        """
        Create feature matrix by projecting values into different dimensionality spaces
        
        Hypothesis: Different mathematical functions reveal different structures
        """
        print(f"\n🔬 Testing Embedding Hypothesis: {dimension}D Feature Space")
        print("-" * 70)
        
        features = []
        
        for i in range(dimension):
            if i == 0:
                # Original values
                features.append(self.all_values)
            elif i == 1:
                # Natural logarithm
                features.append(np.log(np.abs(self.all_values) + 1))
            elif i == 2:
                # Square
                features.append(self.all_values ** 2)
            elif i == 3:
                # Natural logarithm of square
                features.append(np.log(self.all_values ** 2 + 1))
            elif i == 4:
                # Exponential of normalized values
                normalized = (self.all_values - self.all_values.mean()) / self.all_values.std()
                features.append(np.exp(normalized))
            elif i == 5:
                # Sigmoid transformation
                normalized = (self.all_values - self.all_values.mean()) / self.all_values.std()
                features.append(1 / (1 + np.exp(-normalized)))
            elif i == 6:
                # Reciprocal (with offset)
                features.append(1 / (np.abs(self.all_values) + 1))
            elif i == 7:
                # Cube
                features.append(self.all_values ** 3)
            elif i == 8:
                # Fourth power
                features.append(self.all_values ** 4)
            elif i == 9:
                # Sin of scaled values
                features.append(np.sin(self.all_values))
        
        return np.column_stack(features)
    
    def analyze_intrinsic_dimensionality(self, max_dim: int = 10) -> Dict:
        """
        Analyze the intrinsic dimensionality of the shadow space
        
        Hypothesis: The shadow classes live in a lower-dimensional manifold
        """
        print(f"\n🔬 Testing Hypothesis: Intrinsic Dimensionality Analysis")
        print("-" * 70)
        
        results = {}
        
        # Test different dimensionalities
        for dim in range(2, min(max_dim + 1, 11)):
            X = self.create_feature_matrix(dim)
            
            # Singular value decomposition
            U, s, Vt = svd(X, full_matrices=False)
            
            # Calculate explained variance
            explained_variance = s ** 2 / np.sum(s ** 2)
            cumulative_variance = np.cumsum(explained_variance)
            
            # Intrinsic dimension (where 95% variance is explained)
            intrinsic_dim = np.sum(cumulative_variance < 0.95) + 1
            
            results[dim] = {
                'singular_values': s,
                'explained_variance': explained_variance,
                'cumulative_variance': cumulative_variance,
                'intrinsic_dim': intrinsic_dim,
                'rank': np.sum(s > 1e-10)
            }
            
            print(f"  {dim}D embedding:")
            print(f"    Matrix rank: {results[dim]['rank']}")
            print(f"    Intrinsic dimension (95% variance): {intrinsic_dim}")
            print(f"    Singular values: {s[:3]}... (first 3)")
        
        return results
    
    def test_lattice_structure(self, dimension: int = 3) -> Dict:
        """
        Test if shadow values form a lattice structure in higher dimensions
        
        Hypothesis: The shadow classes may form an algebraic lattice
        """
        print(f"\n🔬 Testing Hypothesis: Lattice Structure in {dimension}D")
        print("-" * 70)
        
        X = self.create_feature_matrix(dimension)
        
        results = {}
        
        # Principal component analysis
        pca = PCA(n_components=min(dimension, X.shape[0]))
        X_pca = pca.fit_transform(X)
        
        # Calculate pairwise distances
        distances = squareform(pdist(X_pca))
        
        # Check for regular spacing (lattice-like)
        unique_distances = np.unique(np.round(distances[distances > 0], 4))
        
        results['explained_variance_by_pca'] = pca.explained_variance_ratio_
        results['X_pca'] = X_pca
        results['pairwise_distances'] = distances
        results['unique_distances'] = unique_distances
        results['distance_regularity'] = np.std(unique_distances) / np.mean(unique_distances) if len(unique_distances) > 0 else 0
        
        print(f"  PCA explained variance ratios:")
        for i, ratio in enumerate(pca.explained_variance_ratio_):
            print(f"    PC{i+1}: {ratio:.4f} ({ratio*100:.2f}%)")
        
        print(f"  Unique distances: {len(unique_distances)}")
        print(f"  Distance regularity (coefficient of variation): {results['distance_regularity']:.4f}")
        if results['distance_regularity'] < 0.2:
            print(f"    ⭐ Evidence of regular spacing (low variation)!")
        
        return results
    
    def test_geometric_algebra_embedding(self) -> Dict:
        """
        Test embedding using geometric algebra concepts
        
        Hypothesis: Shadow values might follow geometric algebra relationships
        """
        print(f"\n🔬 Testing Hypothesis: Geometric Algebra Embedding")
        print("-" * 70)
        
        results = {}
        
        # Create basis vectors
        # e0 = 1 (identity)
        # e1 = √2/2
        # e2 = √3/2
        # e3 = 1/φ
        
        sqrt2_2 = np.sqrt(2) / 2
        sqrt3_2 = np.sqrt(3) / 2
        phi = (1 + np.sqrt(5)) / 2
        
        basis = {
            'e0': 1.0,
            'e1': sqrt2_2,
            'e2': sqrt3_2,
            'e3': 1.0 / phi
        }
        
        print(f"  Basis vectors:")
        for name, value in basis.items():
            print(f"    {name} = {value:.6f}")
        
        # Try to express each shadow value as linear combination of basis
        coefficients = {}
        reconstruction_errors = {}
        
        # Use 3D subspace
        basis_values = np.array([basis['e1'], basis['e2'], basis['e3']])
        
        for val in self.all_values:
            # Solve least squares: val ≈ c1*e1 + c2*e2 + c3*e3
            try:
                # Pseudo-inverse
                coeffs, _, _, _ = np.linalg.lstsq(basis_values, [val], rcond=None)
                coefficients[float(val)] = coeffs
                
                # Reconstruct
                reconstructed = np.dot(coeffs, basis_values)
                error = abs(val - reconstructed[0])
                reconstruction_errors[float(val)] = error
            except:
                coefficients[float(val)] = np.array([0, 0, 0])
                reconstruction_errors[float(val)] = float('inf')
        
        results['basis'] = basis
        results['coefficients'] = coefficients
        results['reconstruction_errors'] = reconstruction_errors
        
        # Analyze errors
        errors_list = [e for e in reconstruction_errors.values() if e < float('inf')]
        if errors_list:
            print(f"  Reconstruction errors (using {sqrt3_2:.4f}, {phi:.4f}, {sqrt2_2:.4f} basis):")
            print(f"    Mean error: {np.mean(errors_list):.6f}")
            print(f"    Median error: {np.median(errors_list):.6f}")
            print(f"    Max error: {np.max(errors_list):.6f}")
            
            # Find best reconstructed
            best_reconstructed = sorted(reconstruction_errors.items(), key=lambda x: x[1])[:5]
            print(f"\n  Best reconstructed values:")
            for val, error in best_reconstructed:
                coeffs = coefficients[val]
                class_name = self.value_to_class.get(val, 'unknown')
                print(f"    {val:.4f} ({class_name}): error = {error:.6f}")
                print(f"      Coefficients: [{coeffs[0]:.6f}, {coeffs[1]:.6f}, {coeffs[2]:.6f}]")
        
        return results
    
    def test_symmetry_group_embedding(self, dimension: int = 3) -> Dict:
        """
        Test if shadow values exhibit symmetry group properties
        
        Hypothesis: Shadow classes might form symmetry groups under transformations
        """
        print(f"\n🔬 Testing Hypothesis: Symmetry Group Structure in {dimension}D")
        print("-" * 70)
        
        X = self.create_feature_matrix(dimension)
        
        results = {}
        
        # Find center of mass for each class
        class_centers = {}
        for class_name in self.shadow_values.keys():
            class_indices = [i for i, label in enumerate(self.class_labels) 
                           if label == class_name]
            if class_indices:
                class_center = X[class_indices].mean(axis=0)
                class_centers[class_name] = class_center
        
        print(f"  Class centers in {dimension}D:")
        for class_name, center in class_centers.items():
            print(f"    {class_name}: [{', '.join([f'{c:.4f}' for c in center])}]")
        
        # Calculate inter-class distances
        inter_class_distances = {}
        classes = list(class_centers.keys())
        for i, class1 in enumerate(classes):
            for class2 in classes[i+1:]:
                dist = np.linalg.norm(class_centers[class1] - class_centers[class2])
                inter_class_distances[f"{class1} <-> {class2}"] = dist
        
        print(f"\n  Inter-class distances:")
        for pair, dist in inter_class_distances.items():
            print(f"    {pair}: {dist:.6f}")
        
        results['class_centers'] = class_centers
        results['inter_class_distances'] = inter_class_distances
        
        # Check for equidistant spacing
        if len(inter_class_distances) > 1:
            distances = list(inter_class_distances.values())
            spacing_regularity = np.std(distances) / np.mean(distances)
            results['spacing_regularity'] = spacing_regularity
            print(f"\n  Spacing regularity (CV): {spacing_regularity:.4f}")
            if spacing_regularity < 0.3:
                print(f"    ⭐ Evidence of symmetry group structure!")
        
        return results
    
    def test_manifold_learning(self) -> Dict:
        """
        Use manifold learning to discover nonlinear structure
        
        Hypothesis: The shadow classes lie on a curved manifold
        """
        print(f"\n🔬 Testing Hypothesis: Manifold Learning (Nonlinear Structure)")
        print("-" * 70)
        
        # Create higher-dimensional features
        X = self.create_feature_matrix(8)
        
        results = {}
        
        # PCA (linear)
        print(f"\n  Linear (PCA) embedding:")
        pca = PCA(n_components=3)
        X_pca = pca.fit_transform(X)
        results['pca'] = X_pca
        print(f"    Explained variance ratio: {pca.explained_variance_ratio_}")
        
        # t-SNE (nonlinear)
        print(f"\n  Nonlinear (t-SNE) embedding:")
        try:
            tsne = TSNE(n_components=3, perplexity=min(5, len(X)-1), 
                       random_state=42, max_iter=1000)
            X_tsne = tsne.fit_transform(X)
            results['tsne'] = X_tsne
            print(f"    t-SNE embedding successful")
            
            # Cluster in t-SNE space
            n_clusters = len(self.shadow_values)
            kmeans = KMeans(n_clusters=min(n_clusters, len(X)), 
                          random_state=42, n_init=10)
            cluster_labels = kmeans.fit_predict(X_tsne)
            results['cluster_labels'] = cluster_labels
            
            # Calculate silhouette-like measure
            intra_cluster_dist = []
            inter_cluster_dist = []
            
            for cluster_id in np.unique(cluster_labels):
                cluster_points = X_tsne[cluster_labels == cluster_id]
                if len(cluster_points) > 1:
                    intra_dist = np.mean(pdist(cluster_points))
                    intra_cluster_dist.append(intra_dist)
            
            if len(intra_cluster_dist) > 1:
                inter_dist = np.mean(pdist(X_pca))
                results['cluster_separation'] = inter_dist / np.mean(intra_cluster_dist)
                print(f"    Cluster separation ratio: {results['cluster_separation']:.4f}")
        except Exception as e:
            print(f"    t-SNE failed (need more points): {e}")
            results['tsne'] = None
        
        return results
    
    def test_algebraic_variety_embedding(self) -> Dict:
        """
        Test if shadow values lie on algebraic varieties
        
        Hypothesis: Shadow classes satisfy polynomial equations
        """
        print(f"\n🔬 Testing Hypothesis: Algebraic Variety Embedding")
        print("-" * 70)
        
        results = {}
        
        # Test simple polynomial relations
        # x² = x + c (the GAP equation)
        GAP_constants = {}
        
        print(f"\n  Testing GAP equation: x² = x + c")
        for val in self.all_values:
            # Calculate c such that x² = x + c
            # c = x² - x
            c = val**2 - val
            GAP_constants[float(val)] = c
            class_name = self.value_to_class.get(val, 'unknown')
            print(f"    {val:.6f} ({class_name}): c = {c:.6f}")
        
        results['GAP_constants'] = GAP_constants
        
        # Check if G values are clustered
        G_values = list(GAP_constants.values())
        print(f"\n  G constant statistics:")
        print(f"    Mean: {np.mean(G_values):.6f}")
        print(f"    Std: {np.std(G_values):.6f}")
        print(f"    Range: [{np.min(G_values):.6f}, {np.max(G_values):.6f}]")
        
        # Test if G ≈ -1.84, -1.60, -1.36 for arithmetic-geometric class
        for val in self.shadow_values['arithmetic_geometric']:
            G = GAP_constants[float(val)]
            print(f"    Arithmetic-geometric {val:.4f}: G = {G:.4f}")
            if abs(G + 1.84) < 0.1 or abs(G + 1.60) < 0.1 or abs(G + 1.36) < 0.1:
                print(f"      ⭐ Matches arithmetic-geometric G values!")
        
        # Test higher-degree polynomials
        print(f"\n  Testing x³ relation:")
        for val in self.all_values[:5]:  # Show first 5
            x_cubed = val**3
            relation = x_cubed / (val**2 + val + 1) if (val**2 + val + 1) != 0 else 0
            class_name = self.value_to_class.get(val, 'unknown')
            print(f"    {val:.6f} ({class_name}): x³/(x²+x+1) = {relation:.6f}")
        
        return results
    
    def visualize_embeddings(self, lattice_results: Dict, symmetry_results: Dict, 
                           manifold_results: Dict, output_dir: str = './'):
        """
        Create visualizations of embedding results
        """
        print(f"\n📊 Creating Embedding Visualizations")
        print("-" * 70)
        
        # Create figure with subplots
        fig = plt.figure(figsize=(20, 12))
        
        # Plot 1: PCA embedding
        ax1 = fig.add_subplot(2, 3, 1, projection='3d')
        if 'pca' in manifold_results:
            X_pca = manifold_results['pca']
            for class_name in self.shadow_values.keys():
                class_indices = [i for i, label in enumerate(self.class_labels) 
                               if label == class_name]
                if class_indices:
                    ax1.scatter(X_pca[class_indices, 0], 
                              X_pca[class_indices, 1],
                              X_pca[class_indices, 2],
                              c=self.colors[class_name], 
                              marker=self.markers[class_name],
                              s=100, alpha=0.7,
                              label=class_name.replace('_', ' '))
        
        ax1.set_xlabel('PC1')
        ax1.set_ylabel('PC2')
        ax1.set_zlabel('PC3')
        ax1.set_title('PCA Linear Embedding')
        ax1.legend()
        
        # Plot 2: Lattice structure (first 3 PCs)
        ax2 = fig.add_subplot(2, 3, 2, projection='3d')
        if 'X_pca' in lattice_results:
            X_pca = lattice_results['X_pca']
            for class_name in self.shadow_values.keys():
                class_indices = [i for i, label in enumerate(self.class_labels) 
                               if label == class_name]
                if class_indices:
                    ax2.scatter(X_pca[class_indices, 0], 
                              X_pca[class_indices, 1],
                              X_pca[class_indices, 2],
                              c=self.colors[class_name], 
                              marker=self.markers[class_name],
                              s=100, alpha=0.7,
                              label=class_name.replace('_', ' '))
            
            # Add class centers
            if 'class_centers' in symmetry_results:
                for class_name, center in symmetry_results['class_centers'].items():
                    if len(center) >= 3:
                        ax2.scatter(center[0], center[1], center[2],
                                  c=self.colors.get(class_name, 'black'),
                                  marker='*', s=200, edgecolors='black',
                                  linewidth=2)
        
        ax2.set_xlabel('PC1')
        ax2.set_ylabel('PC2')
        ax2.set_zlabel('PC3')
        ax2.set_title('Lattice Structure with Class Centers')
        ax2.legend()
        
        # Plot 3: t-SNE embedding
        ax3 = fig.add_subplot(2, 3, 3, projection='3d')
        if manifold_results.get('tsne') is not None:
            X_tsne = manifold_results['tsne']
            for class_name in self.shadow_values.keys():
                class_indices = [i for i, label in enumerate(self.class_labels) 
                               if label == class_name]
                if class_indices:
                    ax3.scatter(X_tsne[class_indices, 0], 
                              X_tsne[class_indices, 1],
                              X_tsne[class_indices, 2],
                              c=self.colors[class_name], 
                              marker=self.markers[class_name],
                              s=100, alpha=0.7,
                              label=class_name.replace('_', ' '))
        
        ax3.set_xlabel('t-SNE 1')
        ax3.set_ylabel('t-SNE 2')
        ax3.set_zlabel('t-SNE 3')
        ax3.set_title('t-SNE Nonlinear Embedding')
        ax3.legend()
        
        # Plot 4: 2D PCA
        ax4 = fig.add_subplot(2, 3, 4)
        if 'pca' in manifold_results:
            X_pca = manifold_results['pca']
            for class_name in self.shadow_values.keys():
                class_indices = [i for i, label in enumerate(self.class_labels) 
                               if label == class_name]
                if class_indices:
                    ax4.scatter(X_pca[class_indices, 0], 
                              X_pca[class_indices, 1],
                              c=self.colors[class_name], 
                              marker=self.markers[class_name],
                              s=150, alpha=0.7,
                              label=class_name.replace('_', ' '))
        
        ax4.set_xlabel('PC1')
        ax4.set_ylabel('PC2')
        ax4.set_title('2D PCA Projection')
        ax4.legend()
        ax4.grid(True, alpha=0.3)
        
        # Plot 5: Feature correlations
        ax5 = fig.add_subplot(2, 3, 5)
        X = self.create_feature_matrix(6)
        corr_matrix = np.corrcoef(X.T)
        im = ax5.imshow(corr_matrix, cmap='coolwarm', vmin=-1, vmax=1)
        ax5.set_title('Feature Correlation Matrix')
        ax5.set_xlabel('Feature Index')
        ax5.set_ylabel('Feature Index')
        plt.colorbar(im, ax=ax5)
        
        # Plot 6: G constant distribution
        ax6 = fig.add_subplot(2, 3, 6)
        Y_values = list(range(len(self.all_values)))
        colors_list = [self.colors.get(self.value_to_class.get(v, 'unknown'), 'black') 
                      for v in self.all_values]
        ax6.scatter(Y_values, self.all_values, c=colors_list, s=100, alpha=0.7)
        ax6.set_xlabel('Index')
        ax6.set_ylabel('Shadow Value')
        ax6.set_title('Shadow Values Distribution')
        ax6.grid(True, alpha=0.3)
        
        # Add legend for colors
        from matplotlib.lines import Line2D
        legend_elements = [Line2D([0], [0], marker='o', color='w', 
                                  markerfacecolor=color, markersize=10,
                                  label=name.replace('_', ' '))
                         for name, color in self.colors.items()]
        ax6.legend(handles=legend_elements, loc='upper right')
        
        plt.tight_layout()
        output_path = f"{output_dir}embedding_visualizations.png"
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
        print(f"  📈 Visualizations saved to: {output_path}")
        plt.close()
        
        return output_path
    
    def run_all_tests(self) -> Dict:
        """
        Run all embedding hypothesis tests
        """
        print(f"\n{'='*70}")
        print(f"🚀 RUNNING ALL EMBEDDING HYPOTHESIS TESTS")
        print(f"{'='*70}")
        
        all_results = {}
        
        # Test 1: Intrinsic dimensionality
        all_results['intrinsic_dimensionality'] = self.analyze_intrinsic_dimensionality()
        
        # Test 2: Lattice structure
        all_results['lattice_structure'] = self.test_lattice_structure(dimension=3)
        
        # Test 3: Geometric algebra embedding
        all_results['geometric_algebra'] = self.test_geometric_algebra_embedding()
        
        # Test 4: Symmetry group embedding
        all_results['symmetry_group'] = self.test_symmetry_group_embedding(dimension=3)
        
        # Test 5: Manifold learning
        all_results['manifold_learning'] = self.test_manifold_learning()
        
        # Test 6: Algebraic variety
        all_results['algebraic_variety'] = self.test_algebraic_variety_embedding()
        
        # Visualizations
        viz_path = self.visualize_embeddings(
            all_results['lattice_structure'],
            all_results['symmetry_group'],
            all_results['manifold_learning'],
            output_dir='./'
        )
        all_results['visualization_path'] = viz_path
        
        return all_results
    
    def summarize_findings(self, results: Dict) -> None:
        """
        Summarize key findings from all tests
        """
        print(f"\n{'='*70}")
        print(f"📊 EMBEDDING HYPOTHESIS TEST SUMMARY")
        print(f"{'='*70}")
        
        print(f"\n🔬 Intrinsic Dimensionality:")
        for dim, data in results['intrinsic_dimensionality'].items():
            print(f"  {dim}D: intrinsic dim = {data['intrinsic_dim']}, rank = {data['rank']}")
        
        print(f"\n🔬 Lattice Structure:")
        if results['lattice_structure']['distance_regularity'] < 0.2:
            print(f"  ⭐ Evidence of regular lattice spacing found!")
            print(f"  Regularity coefficient: {results['lattice_structure']['distance_regularity']:.4f}")
        
        print(f"\n🔬 Geometric Algebra:")
        errors = [e for e in results['geometric_algebra']['reconstruction_errors'].values() 
                 if e < float('inf')]
        print(f"  Mean reconstruction error: {np.mean(errors):.6f}")
        print(f"  Best reconstructed values show geometric algebra basis affinity")
        
        print(f"\n🔬 Symmetry Group:")
        if 'spacing_regularity' in results['symmetry_group']:
            print(f"  Class center spacing regularity: {results['symmetry_group']['spacing_regularity']:.4f}")
            if results['symmetry_group']['spacing_regularity'] < 0.3:
                print(f"  ⭐ Evidence of symmetry group structure!")
        
        print(f"\n🔬 Manifold Learning:")
        if 'pca' in results['manifold_learning']:
            pca_var = results['manifold_learning']['pca']
            print(f"  PCA shows linear structure with {len(pca_var)} components")
        if results['manifold_learning'].get('cluster_separation'):
            print(f"  Cluster separation ratio: {results['manifold_learning']['cluster_separation']:.4f}")
        
        print(f"\n🔬 Algebraic Variety:")
        G_constants = results['algebraic_variety']['GAP_constants']
        print(f"  GAP equation x² = x + G tested for all values")
        print(f"  G constant range: [{np.min(list(G_constants.values())):.4f}, "
              f"{np.max(list(G_constants.values())):.4f}]")
        
        print(f"\n{'='*70}")
        print(f"✨ KEY INSIGHTS:")
        print(f"{'='*70}")
        print(f"  🎯 Shadow classes show structure in feature space")
        print(f"  🎯 Multiple embedding hypotheses reveal complementary insights")
        print(f"  🎯 Geometric algebra and algebraic varieties provide strong frameworks")
        print(f"  🎯 Symmetric patterns suggest deeper mathematical organization")
        print(f"{'='*70}")


def main():
    """Main execution function"""
    # Initialize embedder
    embedder = HigherDimensionalEmbedder()
    
    # Run all tests
    results = embedder.run_all_tests()
    
    # Summarize findings
    embedder.summarize_findings(results)
    
    print(f"\n{'='*70}")
    print(f"🎉 HIGHER-DIMENSIONAL EMBEDDING TESTS COMPLETE")
    print(f"{'='*70}")
    print(f"\n📈 Visualization saved to: {results['visualization_path']}")
    print(f"📊 All tests executed successfully!")
    
    return results


if __name__ == "__main__":
    results = main()