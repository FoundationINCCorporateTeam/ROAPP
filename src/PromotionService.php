<?php
/**
 * Roblox Group Promotion Service
 * 
 * Handles promoting users in Roblox groups using Cloud API
 */
class PromotionService {
    private $apiKey;
    
    public function __construct() {
        $this->apiKey = Env::get('ROBLOX_API_KEY');
        
        if (!$this->apiKey) {
            throw new Exception('ROBLOX_API_KEY not configured');
        }
    }
    
    /**
     * Promote a user to a specific role
     * 
     * @param int $groupId Group ID
     * @param int $userId User ID to promote
     * @param string $targetRole Target role path (e.g., "groups/7/roles/99513316")
     * @return array Result with success status and message
     */
    public function promoteUser($groupId, $userId, $targetRole) {
        // First, get the membership ID
        $membershipId = $this->getMembershipId($groupId, $userId);
        
        if (!$membershipId) {
            return [
                'success' => false,
                'message' => 'User is not a member of the group'
            ];
        }
        
        // Update the membership role
        $result = $this->updateMembershipRole($groupId, $membershipId, $targetRole);
        
        return $result;
    }
    
    /**
     * Get membership ID for a user in a group
     */
    private function getMembershipId($groupId, $userId) {
        $url = "https://apis.roblox.com/cloud/v2/groups/{$groupId}/memberships";
        
        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'x-api-key: ' . $this->apiKey
            ],
            CURLOPT_TIMEOUT => 15
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        
        curl_close($ch);
        
        if ($error) {
            throw new Exception("Failed to get memberships: $error");
        }
        
        if ($httpCode !== 200) {
            throw new Exception("Failed to get memberships: HTTP $httpCode");
        }
        
        $data = json_decode($response, true);
        
        if (!isset($data['groupMemberships'])) {
            return null;
        }
        
        // Find the membership for this user
        foreach ($data['groupMemberships'] as $membership) {
            if (isset($membership['user']) && 
                strpos($membership['user'], "users/{$userId}") !== false) {
                return $membership['path'];
            }
        }
        
        return null;
    }
    
    /**
     * Update membership role
     */
    private function updateMembershipRole($groupId, $membershipPath, $targetRole) {
        // Extract membership ID from path
        $parts = explode('/', $membershipPath);
        $membershipId = end($parts);
        
        $url = "https://apis.roblox.com/cloud/v2/groups/{$groupId}/memberships/{$membershipId}";
        
        $payload = [
            'role' => $targetRole
        ];
        
        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => 'PATCH',
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => [
                'x-api-key: ' . $this->apiKey,
                'Content-Type: application/json'
            ],
            CURLOPT_TIMEOUT => 15
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        
        curl_close($ch);
        
        if ($error) {
            return [
                'success' => false,
                'message' => "Promotion failed: $error"
            ];
        }
        
        if ($httpCode !== 200) {
            $errorData = json_decode($response, true);
            $errorMsg = $errorData['message'] ?? 'Unknown error';
            
            return [
                'success' => false,
                'message' => "Promotion failed: HTTP $httpCode - $errorMsg"
            ];
        }
        
        return [
            'success' => true,
            'message' => 'User promoted successfully'
        ];
    }
    
    /**
     * Get user info from Roblox
     * 
     * @param int $userId User ID
     * @return array|null User info or null
     */
    public function getUserInfo($userId) {
        $url = "https://users.roblox.com/v1/users/{$userId}";
        
        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        curl_close($ch);
        
        if ($httpCode === 200) {
            return json_decode($response, true);
        }
        
        return null;
    }
}
